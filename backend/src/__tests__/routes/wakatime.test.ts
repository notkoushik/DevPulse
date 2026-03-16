import { fetchWakaTimeData } from '../../routes/wakatime';
import axios from 'axios';
import { cache } from '../../cache';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

describe('wakatime.ts - fetchWakaTimeData', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        cache.clear();
    });

    const mockToday = {
        data: {
            grand_total: {
                text: '5 hrs 30 mins',
                total_seconds: 19800,
            }
        }
    };

    const mockWeek = {
        data: {
            human_readable_total_including_other_language: '35 hrs',
            total_seconds_including_other_language: 126000,
            human_readable_daily_average_including_other_language: '5 hrs',
            languages: [
                { name: 'TypeScript', percent: 60.5, total_seconds: 76230, text: '21 hrs 10 mins' },
                { name: 'Dart', percent: 39.5, total_seconds: 49770, text: '13 hrs 50 mins' }
            ],
            editors: [
                { name: 'VS Code', percent: 100, text: '35 hrs' }
            ],
            projects: [
                { name: 'DevPulse', percent: 100, total_seconds: 126000, text: '35 hrs' }
            ],
            days: [
                { date: '2023-10-01', total: 18000 },
                { date: '2023-10-02', total: 19800 }
            ]
        }
    };

    it('should fetch and parse WakaTime data correctly', async () => {
        // Mock today and week parallel fetches
        mockedAxios.get.mockResolvedValueOnce({ data: mockToday });
        mockedAxios.get.mockResolvedValueOnce({ data: mockWeek });

        const result = await fetchWakaTimeData('user123', 'test_waka_key');

        expect(result.today.text).toBe('5 hrs 30 mins');
        expect(result.today.totalSeconds).toBe(19800);
        
        expect(result.week.text).toBe('35 hrs');
        expect(result.week.totalSeconds).toBe(126000);
        expect(result.week.dailyAverage).toBe('5 hrs');

        expect(result.languages).toHaveLength(2);
        expect(result.languages[0].name).toBe('TypeScript');
        expect(result.languages[0].color).toBe('#3178C6'); // From _getLanguageColor mapping

        expect(result.editors).toHaveLength(1);
        expect(result.projects).toHaveLength(1);

        expect(result.dailyCoding).toHaveLength(2);
        expect(result.dailyCoding[0].text).toBe('5h 0m'); // formatted from 18000s

        // Verify correct Auth header base64 encoding sent
        const expectedAuth = `Basic ${Buffer.from('test_waka_key').toString('base64')}`;
        expect(mockedAxios.get).toHaveBeenCalledWith(
            expect.any(String),
            expect.objectContaining({ headers: { Authorization: expectedAuth } })
        );
    });

    it('should generate fallback daily coding if days array is missing', async () => {
        const weekWithoutDays = { ...mockWeek };
        weekWithoutDays.data.days = []; // Empty days

        mockedAxios.get.mockResolvedValueOnce({ data: mockToday });
        mockedAxios.get.mockResolvedValueOnce({ data: weekWithoutDays });

        const result = await fetchWakaTimeData('user123', 'test_key');

        // Should fall back to _generateDailyFromWeek which generates 7 days
        expect(result.dailyCoding).toHaveLength(7);
        // Approximate values should be calculated
        expect(result.dailyCoding[0].totalSeconds).toBeGreaterThan(0);
    });

    it('should handle API failures gracefully by returning defaults', async () => {
        // Both requests fail (the actual code catches them and returns null)
        mockedAxios.get.mockRejectedValue(new Error('WakaTime API Down'));

        const result = await fetchWakaTimeData('user123', 'test_key');

        expect(result.today.text).toBe('0 hrs 0 mins');
        expect(result.week.text).toBe('0 hrs');
        expect(result.languages).toEqual([]);
        expect(result.dailyCoding).toHaveLength(7); // Fallback generates 7 days of 0s
    });

    it('should return cached data if available', async () => {
        const cachedData = { today: { text: '1 hr' } };
        cache.set('wakatime_stats_user123', cachedData);

        const result = await fetchWakaTimeData('user123', 'test_key');

        expect(result).toEqual(cachedData);
        expect(mockedAxios.get).not.toHaveBeenCalled();
    });
});

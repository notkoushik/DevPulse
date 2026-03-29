import request from 'supertest';
import express from 'express';
import { dashboardRouter } from '../../routes/dashboard';
import { fetchGitHubData } from '../../routes/github';
import { fetchLeetCodeData } from '../../routes/leetcode';
import { fetchWakaTimeData } from '../../routes/wakatime';
import { cache } from '../../cache';

// Setup minimal app with Auth Request mock
const app = express();
app.use((req: any, res, next) => {
    req.user = { id: 'user123' };
    req.userProfile = {
        github_username: 'test_gh',
        leetcode_username: 'test_lc',
        wakatime_api_key: 'test_wk',
    };
    next();
});
app.use('/api/dashboard', dashboardRouter);

// Mock the imported fetch functions
jest.mock('../../routes/github');
jest.mock('../../routes/leetcode');
jest.mock('../../routes/wakatime');

const mockFetchGitHub = fetchGitHubData as jest.Mock;
const mockFetchLeetCode = fetchLeetCodeData as jest.Mock;
const mockFetchWakaTime = fetchWakaTimeData as jest.Mock;

describe('dashboardRouter - Integration', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        cache.clear();
    });

    it('should aggregate data successfully from direct function calls', async () => {
        mockFetchGitHub.mockResolvedValueOnce({ stats: 'gh_ok' });
        mockFetchLeetCode.mockResolvedValueOnce({ totalSolved: 10 });
        mockFetchWakaTime.mockResolvedValueOnce({ today: 'waka_ok' });

        const res = await request(app).get('/api/dashboard');

        expect(res.status).toBe(200);
        expect(res.body.github).toEqual({ stats: 'gh_ok' });
        expect(res.body.leetcode).toEqual({ totalSolved: 10 });
        expect(res.body.wakatime).toEqual({ today: 'waka_ok' });
        expect(res.body.timestamp).toBeDefined();

        expect(mockFetchGitHub).toHaveBeenCalledWith('user123', 'test_gh', expect.any(String));
        expect(mockFetchLeetCode).toHaveBeenCalledWith('user123', 'test_lc');
        expect(mockFetchWakaTime).toHaveBeenCalledWith('user123', 'test_wk');

        // Verify caching
        const cached = cache.get<any>('dashboard_user123');
        expect(cached.github).toBeDefined();
    });

    it('should tolerate partial failures in sub-fetches gracefully', async () => {
        mockFetchGitHub.mockResolvedValueOnce({ stats: 'gh_ok' });
        mockFetchLeetCode.mockRejectedValueOnce(new Error('LC Down')); // Simulates LC failure
        mockFetchWakaTime.mockResolvedValueOnce({ today: 'waka_ok' });

        const res = await request(app).get('/api/dashboard');

        expect(res.status).toBe(200);
        expect(res.body.github).toEqual({ stats: 'gh_ok' });
        expect(res.body.leetcode).toBeNull(); // Caught and mapped to null
        expect(res.body.wakatime).toEqual({ today: 'waka_ok' });
    });

    it('should return cached dashboard immediately', async () => {
        const cachedData = {
            github: { mock: 1 },
            leetcode: { mock: 2 },
            wakatime: { mock: 3 },
            timestamp: new Date().toISOString()
        };
        cache.set('dashboard_user123', cachedData);

        const res = await request(app).get('/api/dashboard');

        expect(res.status).toBe(200);
        expect(res.body).toEqual(cachedData);

        // Fetch functions should NOT be called
        expect(mockFetchGitHub).not.toHaveBeenCalled();
        expect(mockFetchLeetCode).not.toHaveBeenCalled();
        expect(mockFetchWakaTime).not.toHaveBeenCalled();
    });
});

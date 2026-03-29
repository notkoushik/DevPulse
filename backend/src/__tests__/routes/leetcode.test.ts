import { fetchLeetCodeData } from '../../routes/leetcode';
import axios from 'axios';
import { cache } from '../../cache';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

describe('leetcode.ts - fetchLeetCodeData', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    cache.clear();
  });

  const mockProfile = {
    matchedUser: {
      username: 'lcuser',
      profile: { ranking: 12345, reputation: 100, starRating: 2 },
      submitStatsGlobal: {
        acSubmissionNum: [
          { difficulty: 'All', count: 50 },
          { difficulty: 'Easy', count: 20 },
          { difficulty: 'Medium', count: 20 },
          { difficulty: 'Hard', count: 10 },
        ]
      },
      badges: [{ name: '100 Days Badge' }]
    },
    allQuestionsCount: [
      { difficulty: 'All', count: 3000 },
      { difficulty: 'Easy', count: 800 },
      { difficulty: 'Medium', count: 1600 },
      { difficulty: 'Hard', count: 600 },
    ]
  };

  const mockSubmissions = {
    recentAcSubmissionList: [
      { id: '1', title: 'Two Sum', titleSlug: 'two-sum', timestamp: '1690000000', statusDisplay: 'Accepted', lang: 'cpp' },
      { id: '2', title: 'Add Two Numbers', titleSlug: 'add-two-numbers', timestamp: '1690000050', statusDisplay: 'Accepted', lang: 'python' }
    ]
  };

  const mockContest = {
    userContestRanking: {
      attendedContestsCount: 5,
      rating: 1650.5,
      globalRanking: 50000
    }
  };

  it('should fetch and parse LeetCode data correctly', async () => {
    mockedAxios.post.mockResolvedValueOnce({ data: { data: mockProfile } });
    mockedAxios.post.mockResolvedValueOnce({ data: { data: mockSubmissions } });
    mockedAxios.post.mockResolvedValueOnce({ data: { data: mockContest } });
    // Mock the difficulty fetches for 2 submissions
    mockedAxios.post.mockResolvedValueOnce({ data: { data: { question: { difficulty: 'Easy' } } } });
    mockedAxios.post.mockResolvedValueOnce({ data: { data: { question: { difficulty: 'Medium' } } } });

    const result = await fetchLeetCodeData('user123', 'lcuser');

    expect(result.totalSolved).toBe(50);
    expect(result.totalQuestions).toBe(3000);
    expect(result.ranking).toBe(12345);
    expect(result.acceptanceRate).toBe(1.67); // 50/3000 * 100
    expect(result.easy.solved).toBe(20);
    expect(result.medium.solved).toBe(20);
    expect(result.hard.solved).toBe(10);
    expect(result.contestRating).toBe(1651); // rounded
    expect(result.badges).toBe(1);
    expect(result.recentSubmissions).toHaveLength(2);
    expect(result.recentSubmissions[0].title).toBe('Two Sum');
    expect(result.recentSubmissions[0].difficulty).toBe('Easy');
    expect(result.recentSubmissions[1].difficulty).toBe('Medium');
    expect(result.weeklyProgress).toHaveLength(7); // Array of 7 days

    // 3 initial calls (profile, submissions, contest) + 2 difficulty calls
    expect(mockedAxios.post).toHaveBeenCalledTimes(5);
  });

  it('should return cached data if available', async () => {
    const cachedData = { totalSolved: 100 };
    cache.set('leetcode_stats_user123', cachedData);

    const result = await fetchLeetCodeData('user123', 'lcuser');

    expect(result).toEqual(cachedData);
    expect(mockedAxios.post).not.toHaveBeenCalled();
  });

  it('should handle API errors', async () => {
    mockedAxios.post.mockRejectedValueOnce(new Error('LeetCode Error'));

    await expect(fetchLeetCodeData('user123', 'lcuser')).rejects.toThrow('LeetCode Error');
  });
  
  it('should handle missing contest data gracefully', async () => {
    mockedAxios.post.mockResolvedValueOnce({ data: { data: mockProfile } });
    mockedAxios.post.mockResolvedValueOnce({ data: { data: mockSubmissions } });
    mockedAxios.post.mockResolvedValueOnce({ data: { data: { userContestRanking: null } } });

    const result = await fetchLeetCodeData('user123', 'lcuser');
    expect(result.contestRating).toBe(0);
  });
});

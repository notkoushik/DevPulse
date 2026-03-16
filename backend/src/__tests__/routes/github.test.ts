import { fetchGitHubData } from '../../routes/github';
import axios from 'axios';
import { cache } from '../../cache';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

describe('github.ts - fetchGitHubData', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    cache.clear();
  });

  const mockUser = {
    name: 'Test User',
    login: 'testuser',
    avatarUrl: 'https://avatar.url',
    createdAt: '2020-01-01T00:00:00Z',
    repositories: { totalCount: 10 },
    followers: { totalCount: 5 },
    contributionsCollection: {
      totalCommitContributions: 100,
      contributionCalendar: {
        totalContributions: 150,
        weeks: [
          {
            contributionDays: [
              { date: '2023-10-01', contributionCount: 0, contributionLevel: 'NONE' },
              { date: '2023-10-02', contributionCount: 5, contributionLevel: 'FIRST_QUARTILE' },
            ]
          }
        ]
      }
    },
    starredRepositories: { totalCount: 2 },
    pullRequests: { totalCount: 1 },
    mergedPRs: { totalCount: 2 },
    closedPRs: { totalCount: 3 },
    openIssues: { totalCount: 4 },
    closedIssues: { totalCount: 5 },
  };

  const mockRepos = {
    nodes: [
      {
        name: 'repo1',
        primaryLanguage: { name: 'TypeScript', color: '#3178c6' },
        stargazerCount: 10,
        updatedAt: new Date().toISOString(),
        defaultBranchRef: { target: { history: { totalCount: 50 } } }
      }
    ]
  };

  it('should fetch and parse GitHub data correctly', async () => {
    mockedAxios.post.mockResolvedValueOnce({ data: { data: { user: mockUser } } }); // Contributions
    mockedAxios.post.mockResolvedValueOnce({ data: { data: { user: { repositories: mockRepos } } } }); // Repos

    const result = await fetchGitHubData('user123', 'testuser');

    expect(result.username).toBe('testuser');
    expect(result.user.name).toBe('Test User');
    expect(result.user.totalCommits).toBe(100);
    expect(result.user.totalStars).toBe(10);
    expect(result.stats.recentRepos).toHaveLength(1);
    expect(result.stats.recentRepos[0].language).toBe('TypeScript');
    
    // Compute streak correctly based on the mock data (last day has 5 commits)
    expect(result.user.streak).toBe(1);

    expect(mockedAxios.post).toHaveBeenCalledTimes(2);
  });

  it('should return cached data if available', async () => {
    const cachedData = { username: 'cacheduser', stats: {} };
    cache.set('github_stats_user123', cachedData);

    const result = await fetchGitHubData('user123', 'testuser');

    expect(result).toEqual(cachedData);
    expect(mockedAxios.post).not.toHaveBeenCalled();
  });

  it('should handle API errors', async () => {
    mockedAxios.post.mockRejectedValueOnce(new Error('GitHub API Error'));

    await expect(fetchGitHubData('user123', 'testuser')).rejects.toThrow('GitHub API Error');
  });
});

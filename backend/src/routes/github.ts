import { Router } from 'express';
import axios from 'axios';
import { cache } from '../cache';
import { AuthRequest } from '../middleware/auth';
import { timeAgo } from '../utils/timeAgo';

export const githubRouter = Router();

const GITHUB_GRAPHQL = 'https://api.github.com/graphql';
const GITHUB_REST = 'https://api.github.com';

// ─── GraphQL query to fetch everything in one shot ───
const CONTRIBUTIONS_QUERY = `
query($username: String!, $from: DateTime!, $to: DateTime!) {
  user(login: $username) {
    name
    login
    avatarUrl
    createdAt
    repositories(first: 100, ownerAffiliations: OWNER, privacy: PUBLIC) {
      totalCount
    }
    followers { totalCount }
    contributionsCollection(from: $from, to: $to) {
      totalCommitContributions
      contributionCalendar {
        totalContributions
        weeks {
          contributionDays {
            date
            contributionCount
            contributionLevel
          }
        }
      }
    }
    starredRepositories { totalCount }
    pullRequests(first: 1, states: [OPEN]) { totalCount }
    mergedPRs: pullRequests(first: 1, states: [MERGED]) { totalCount }
    closedPRs: pullRequests(first: 1, states: [CLOSED]) { totalCount }
    openIssues: issues(first: 1, states: [OPEN]) { totalCount }
    closedIssues: issues(first: 1, states: [CLOSED]) { totalCount }
  }
}
`;

const REPOS_QUERY = `
query($username: String!) {
  user(login: $username) {
    repositories(first: 10, ownerAffiliations: OWNER, orderBy: {field: UPDATED_AT, direction: DESC}, privacy: PUBLIC) {
      nodes {
        name
        primaryLanguage { name color }
        stargazerCount
        defaultBranchRef {
          target {
            ... on Commit {
              history(first: 1) { totalCount }
            }
          }
        }
        updatedAt
      }
    }
  }
}
`;

function getHeaders(): Record<string, string> {
  return {
    Authorization: `bearer ${process.env.GITHUB_PAT}`,
    'Content-Type': 'application/json',
  };
}

/**
 * Core data-fetching logic for GitHub stats.
 * Exported so dashboard.ts can call it directly without an HTTP self-call.
 */
export async function fetchGitHubData(userId: string, username: string, timezone: string = 'UTC'): Promise<any> {
    const cached = cache.get<any>('github_stats_' + userId);
    if (cached) return cached;

    const now = new Date();
    const yearAgo = new Date(now);
    yearAgo.setFullYear(yearAgo.getFullYear() - 1);

    // Convert to user's timezone for 'today' calculation
    // GitHub contribution calendar dates use the user's local timezone
    const formatter = new Intl.DateTimeFormat('en-US', {
        timeZone: timezone,
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
    });

    const parts = formatter.formatToParts(now);
    const todayStr = `${parts.find(p => p.type === 'year')?.value}-${parts.find(p => p.type === 'month')?.value}-${parts.find(p => p.type === 'day')?.value}`;

    // Fetch contributions + repos in parallel
    const [contribRes, reposRes] = await Promise.all([
      axios.post(GITHUB_GRAPHQL, {
        query: CONTRIBUTIONS_QUERY,
        variables: {
          username,
          from: yearAgo.toISOString(),
          to: now.toISOString(),
        },
      }, { headers: getHeaders() }),

      axios.post(GITHUB_GRAPHQL, {
        query: REPOS_QUERY,
        variables: { username },
      }, { headers: getHeaders() }),
    ]);

    const user = contribRes.data.data.user;
    const contribs = user.contributionsCollection;
    const calendar = contribs.contributionCalendar;
    const repoNodes = reposRes.data.data.user.repositories.nodes;

    // ─── Parse contribution days (last 30 for grid) ───
    const allDays = calendar.weeks.flatMap((w: any) => w.contributionDays);
    const last30Days = allDays.slice(-30);
    const last7Days = allDays.slice(-7);

    // Level mapping
    const levelMap: Record<string, number> = {
      'NONE': 0, 'FIRST_QUARTILE': 1, 'SECOND_QUARTILE': 2,
      'THIRD_QUARTILE': 3, 'FOURTH_QUARTILE': 4,
    };

    // ─── Compute streak ───
    // If today has no contributions yet (day not over), start from yesterday
    let streak = 0;
    let startIdx = allDays.length - 1;
    if (startIdx >= 0 && allDays[startIdx].contributionCount === 0) {
      startIdx--;
    }
    for (let i = startIdx; i >= 0; i--) {
      if (allDays[i].contributionCount > 0) streak++;
      else break;
    }

    // ─── Today's commits ─── (use user's timezone to match GitHub calendar)
    const todayEntry = allDays.find((d: any) => d.date === todayStr);
    const todayCommits = todayEntry ? todayEntry.contributionCount : 0;

    // ─── Weekly commits ───
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const weeklyCommits = last7Days.map((d: any) => ({
      day: dayNames[new Date(d.date).getDay()],
      commits: d.contributionCount,
    }));

    // ─── Monthly contributions (30 days) ───
    const monthlyContributions = last30Days.map((d: any) => ({
      date: d.date,
      count: d.contributionCount,
      level: levelMap[d.contributionLevel] ?? 0,
    }));

    // ─── Repos with total stars ───
    let totalStars = 0;
    const recentRepos = repoNodes.map((r: any) => {
      totalStars += r.stargazerCount;
      const lang = r.primaryLanguage;
      return {
        name: r.name,
        language: lang?.name ?? 'Unknown',
        languageColor: lang?.color ?? '#888888',
        stars: r.stargazerCount,
        commits: r.defaultBranchRef?.target?.history?.totalCount ?? 0,
        lastActive: timeAgo(new Date(r.updatedAt)),
      };
    });

    const result = {
      username, // include so AI always knows who this is
      user: {
        name: user.name || username,
        username: user.login,
        avatar: user.avatarUrl,
        streak,
        longestStreak: streak,
        totalCommits: contribs.totalCommitContributions,
        totalRepos: contribRes.data.data.user.repositories.totalCount,
        totalStars,
        joinedDate: user.createdAt,
      },
      stats: {
        todayCommits,
        weeklyCommits,
        monthlyContributions,
        recentRepos,
        pullRequests: {
          open: user.pullRequests.totalCount,
          merged: user.mergedPRs.totalCount,
          closed: user.closedPRs.totalCount,
        },
        issues: {
          open: user.openIssues.totalCount,
          closed: user.closedIssues.totalCount,
        },
      },
    };

    cache.set('github_stats_' + userId, result, 300); // 5 min cache
    return result;
}

// ─── /api/github/stats ───
githubRouter.get('/stats', async (req, res) => {
  try {
    const authReq = req as AuthRequest;
    const userId = authReq.user?.id;
    const username = authReq.userProfile?.github_username || process.env.GITHUB_USERNAME;
    // Get user's timezone from Intl API (browser/OS timezone detected server-side)
    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';

    if (!username) {
      return res.status(400).json({
        error: 'GitHub username not configured',
        message: 'Please set GITHUB_USERNAME in environment variables or configure in user profile',
      });
    }

    const result = await fetchGitHubData(userId, username, timezone);
    res.json(result);
  } catch (err: any) {
    console.error('GitHub API error:', err.response?.data || err.message);
    res.status(500).json({
      error: 'Failed to fetch GitHub data',
      message: err.response?.data?.message || err.message,
    });
  }
});

import { Router } from 'express';
import axios from 'axios';
import { cache } from '../cache';
import { AuthRequest } from '../middleware/auth';

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

// ─── /api/github/stats ───
githubRouter.get('/stats', async (req, res) => {
  try {
    const authReq = req as AuthRequest;
    const cached = cache.get<any>('github_stats_' + authReq.user?.id);
    if (cached) return res.json(cached);

    const username = authReq.userProfile?.github_username || process.env.GITHUB_USERNAME || 'notkoushik';
    const now = new Date();
    const yearAgo = new Date(now);
    yearAgo.setFullYear(yearAgo.getFullYear() - 1);

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
    let streak = 0;
    for (let i = allDays.length - 1; i >= 0; i--) {
      if (allDays[i].contributionCount > 0) streak++;
      else break;
    }

    // ─── Today's commits ───
    const todayStr = now.toISOString().split('T')[0];
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
        lastActive: _timeAgo(new Date(r.updatedAt)),
      };
    });

    const result = {
      user: {
        name: user.name || username,
        username: user.login,
        avatar: user.avatarUrl,
        streak,
        longestStreak: streak, // GraphQL doesn't expose longest streak natively
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

    cache.set('github_stats_' + authReq.user?.id, result, 900);
    res.json(result);
  } catch (err: any) {
    console.error('GitHub API error:', err.response?.data || err.message);
    res.status(500).json({
      error: 'Failed to fetch GitHub data',
      details: err.response?.data?.message || err.message,
    });
  }
});

function _timeAgo(date: Date): string {
  const seconds = Math.floor((Date.now() - date.getTime()) / 1000);
  if (seconds < 60) return 'just now';
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  const weeks = Math.floor(days / 7);
  return `${weeks}w ago`;
}

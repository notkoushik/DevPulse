import { Router } from 'express';
import axios from 'axios';
import { cache } from '../cache';
import { AuthRequest } from '../middleware/auth';

export const leetcodeRouter = Router();

const LC_GRAPHQL = 'https://leetcode.com/graphql';

// ─── Queries ───
const USER_PROFILE_QUERY = `
query getUserProfile($username: String!) {
  matchedUser(username: $username) {
    username
    profile {
      ranking
      reputation
      starRating
    }
    submitStatsGlobal {
      acSubmissionNum {
        difficulty
        count
      }
    }
    badges {
      name
    }
  }
  allQuestionsCount {
    difficulty
    count
  }
}
`;

const RECENT_SUBMISSIONS_QUERY = `
query getRecentSubmissions($username: String!, $limit: Int!) {
  recentAcSubmissionList(username: $username, limit: $limit) {
    id
    title
    titleSlug
    timestamp
    statusDisplay
    lang
  }
}
`;

const CONTEST_QUERY = `
query getUserContestRanking($username: String!) {
  userContestRanking(username: $username) {
    attendedContestsCount
    rating
    globalRanking
  }
}
`;

// ─── /api/leetcode/stats ───
leetcodeRouter.get('/stats', async (req, res) => {
  try {
    const authReq = req as AuthRequest;
    const cached = cache.get<any>('leetcode_stats_' + authReq.user?.id);
    if (cached) return res.json(cached);

    const username = authReq.userProfile?.leetcode_username || process.env.LEETCODE_USERNAME || 'koushiknani';

    // Fetch all LC data in parallel
    const [profileRes, submissionsRes, contestRes] = await Promise.all([
      axios.post(LC_GRAPHQL, {
        query: USER_PROFILE_QUERY,
        variables: { username },
      }, {
        headers: {
          'Content-Type': 'application/json',
          'Referer': 'https://leetcode.com',
        },
      }),

      axios.post(LC_GRAPHQL, {
        query: RECENT_SUBMISSIONS_QUERY,
        variables: { username, limit: 10 },
      }, {
        headers: {
          'Content-Type': 'application/json',
          'Referer': 'https://leetcode.com',
        },
      }),

      axios.post(LC_GRAPHQL, {
        query: CONTEST_QUERY,
        variables: { username },
      }, {
        headers: {
          'Content-Type': 'application/json',
          'Referer': 'https://leetcode.com',
        },
      }),
    ]);

    const user = profileRes.data.data.matchedUser;
    const allQuestions = profileRes.data.data.allQuestionsCount;
    const submissions = submissionsRes.data.data.recentAcSubmissionList || [];
    const contest = contestRes.data.data.userContestRanking;

    // Parse difficulty stats
    const acStats = user.submitStatsGlobal.acSubmissionNum;
    const getCount = (diff: string) => acStats.find((s: any) => s.difficulty === diff)?.count || 0;
    const getTotal = (diff: string) => allQuestions.find((q: any) => q.difficulty === diff)?.count || 0;

    const totalSolved = getCount('All');
    const totalQuestions = getTotal('All');

    // Parse recent submissions
    const recentSubmissions = submissions.map((s: any, i: number) => ({
      id: parseInt(s.id) || i,
      title: s.title,
      difficulty: _guessDifficulty(s.titleSlug), // LC doesn't return difficulty in submissions
      status: s.statusDisplay,
      time: _timeAgo(new Date(parseInt(s.timestamp) * 1000)),
      runtime: s.lang,
    }));

    const result = {
      totalSolved,
      totalQuestions,
      ranking: user.profile.ranking,
      acceptanceRate: totalQuestions > 0 ? Math.round((totalSolved / totalQuestions) * 10000) / 100 : 0,
      easy: { solved: getCount('Easy'), total: getTotal('Easy') },
      medium: { solved: getCount('Medium'), total: getTotal('Medium') },
      hard: { solved: getCount('Hard'), total: getTotal('Hard') },
      recentSubmissions,
      contestRating: contest?.rating ? Math.round(contest.rating) : 0,
      badges: user.badges?.length ?? 0,
      weeklyProgress: _generateWeeklyProgress(submissions),
    };

    cache.set('leetcode_stats_' + authReq.user?.id, result, 900);
    res.json(result);
  } catch (err: any) {
    console.error('LeetCode API error:', err.response?.data || err.message);
    res.status(500).json({
      error: 'Failed to fetch LeetCode data',
      details: err.message,
    });
  }
});

// LeetCode submissions don't include difficulty, so we default to "Medium"
function _guessDifficulty(_slug: string): string {
  return 'Medium';
}

// Generate a mock weekly progress from submission timestamps
function _generateWeeklyProgress(submissions: any[]): Array<{ day: string; solved: number }> {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const counts: Record<string, number> = {};
  days.forEach((d) => (counts[d] = 0));

  for (const sub of submissions) {
    const date = new Date(parseInt(sub.timestamp) * 1000);
    const dayName = days[(date.getDay() + 6) % 7]; // Monday = 0
    counts[dayName]++;
  }

  return days.map((day) => ({ day, solved: counts[day] }));
}

function _timeAgo(date: Date): string {
  const seconds = Math.floor((Date.now() - date.getTime()) / 1000);
  if (seconds < 60) return 'just now';
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  return `${Math.floor(days / 7)}w ago`;
}

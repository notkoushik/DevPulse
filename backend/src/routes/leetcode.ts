import { Router } from 'express';
import axios from 'axios';
import { cache } from '../cache';
import { AuthRequest } from '../middleware/auth';
import { timeAgoFromUnix } from '../utils/timeAgo';

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

const PROBLEM_QUERY = `
query getProblem($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    difficulty
  }
}
`;

/**
 * Core data-fetching logic for LeetCode stats.
 * Exported so dashboard.ts can call it directly without an HTTP self-call.
 */
export async function fetchLeetCodeData(userId: string, username: string): Promise<any> {
    const cached = cache.get<any>('leetcode_stats_' + userId);
    if (cached) return cached;

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
    const recentSubmissions = await Promise.all(submissions.map(async (s: any, i: number) => ({
      id: parseInt(s.id) || i,
      title: s.title,
      difficulty: await fetchProblemDifficulty(s.titleSlug),
      status: s.statusDisplay,
      time: timeAgoFromUnix(parseInt(s.timestamp)),
      runtime: s.lang,
    })));

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

    cache.set('leetcode_stats_' + userId, result, 300); // 5 min cache
    return result;
}

// ─── /api/leetcode/stats ───
leetcodeRouter.get('/stats', async (req, res) => {
  try {
    const authReq = req as AuthRequest;
    const userId = authReq.user?.id;
    const username = authReq.userProfile?.leetcode_username || process.env.LEETCODE_USERNAME;

    if (!username) {
      return res.status(400).json({
        error: 'LeetCode username not configured',
        message: 'Please set LEETCODE_USERNAME in environment variables or configure in user profile',
      });
    }

    const result = await fetchLeetCodeData(userId, username);
    res.json(result);
  } catch (err: any) {
    console.error('LeetCode API error:', err.response?.data || err.message);
    res.status(500).json({
      error: 'Failed to fetch LeetCode data',
      message: err.response?.data?.message || err.message,
    });
  }
});

// LeetCode difficulty cache for submissions (stores titleSlug -> difficulty)
const difficultyCache = new Map<string, Promise<string>>();

// Fetch actual difficulty for a problem using its slug
async function fetchProblemDifficulty(titleSlug: string): Promise<string> {
    // Check if we're already fetching this or have it cached
    if (difficultyCache.has(titleSlug)) {
        return difficultyCache.get(titleSlug)!;
    }

    const difficultyPromise = (async () => {
        try {
            const response = await axios.post(LC_GRAPHQL, {
                query: PROBLEM_QUERY,
                variables: { titleSlug },
            }, {
                headers: {
                    'Content-Type': 'application/json',
                    'Referer': 'https://leetcode.com',
                },
            });

            const difficulty = response.data.data?.question?.difficulty || 'Medium';
            // Keep in cache for 24 hours
            setTimeout(() => difficultyCache.delete(titleSlug), 24 * 60 * 60 * 1000);
            return difficulty;
        } catch (err) {
            console.warn(`Failed to fetch difficulty for ${titleSlug}, defaulting to Medium`);
            return 'Medium';
        }
    })();

    difficultyCache.set(titleSlug, difficultyPromise);
    return difficultyPromise;
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

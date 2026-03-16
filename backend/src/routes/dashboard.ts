import { Router } from 'express';
import { cache } from '../cache';
import { AuthRequest } from '../middleware/auth';
import { fetchGitHubData } from './github';
import { fetchLeetCodeData } from './leetcode';
import { fetchWakaTimeData } from './wakatime';

export const dashboardRouter = Router();

/**
 * /api/dashboard — Aggregated endpoint for the home screen.
 * Calls the data-fetching functions directly (not via HTTP self-calls)
 * to avoid wasting rate limit slots and adding unnecessary latency.
 */
dashboardRouter.get('/', async (req, res) => {
    try {
        const authReq = req as AuthRequest;
        const userId = authReq.user?.id;
        const cached = cache.get<any>('dashboard_' + userId);
        if (cached) return res.json(cached);

        const githubUsername = authReq.userProfile?.github_username || process.env.GITHUB_USERNAME || 'notkoushik';
        const leetcodeUsername = authReq.userProfile?.leetcode_username || process.env.LEETCODE_USERNAME || 'koushiknani';
        const wakatimeKey = authReq.userProfile?.wakatime_api_key || process.env.WAKATIME_API_KEY || '';

        // Fetch all data in parallel via direct function calls (no HTTP overhead)
        const [githubData, leetcodeData, wakatimeData] = await Promise.all([
            fetchGitHubData(userId, githubUsername).catch(() => null),
            fetchLeetCodeData(userId, leetcodeUsername).catch(() => null),
            fetchWakaTimeData(userId, wakatimeKey).catch(() => null),
        ]);

        const result = {
            github: githubData,
            leetcode: leetcodeData,
            wakatime: wakatimeData,
            timestamp: new Date().toISOString(),
        };

        cache.set('dashboard_' + userId, result, 600); // 10 min cache
        res.json(result);
    } catch (err: any) {
        console.error('Dashboard aggregation error:', err.message);
        res.status(500).json({
            error: 'Failed to aggregate dashboard data',
            details: err.message,
        });
    }
});

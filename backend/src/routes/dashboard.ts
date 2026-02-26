import { Router } from 'express';
import axios from 'axios';
import { cache } from '../cache';
import { AuthRequest } from '../middleware/auth';

export const dashboardRouter = Router();

/**
 * /api/dashboard — Aggregated endpoint for the home screen.
 * Fetches from the other internal routes and combines everything
 * the Dashboard screen needs in a single response.
 */
dashboardRouter.get('/', async (req, res) => {
    try {
        const authReq = req as AuthRequest;
        const cached = cache.get<any>('dashboard_' + authReq.user?.id);
        if (cached) return res.json(cached);

        const baseUrl = `${req.protocol}://${req.get('host')}`;

        // Forward Authorization header
        const headers = { Authorization: req.headers.authorization };

        // Fetch all data in parallel from other routes
        const [githubRes, leetcodeRes, wakatimeRes] = await Promise.all([
            axios.get(`${baseUrl}/api/github/stats`, { headers }).catch(() => ({ data: null })),
            axios.get(`${baseUrl}/api/leetcode/stats`, { headers }).catch(() => ({ data: null })),
            axios.get(`${baseUrl}/api/wakatime/stats`, { headers }).catch(() => ({ data: null })),
        ]);

        const result = {
            github: githubRes.data,
            leetcode: leetcodeRes.data,
            wakatime: wakatimeRes.data,
            timestamp: new Date().toISOString(),
        };

        cache.set('dashboard_' + authReq.user?.id, result, 600); // 10 min cache
        res.json(result);
    } catch (err: any) {
        console.error('Dashboard aggregation error:', err.message);
        res.status(500).json({
            error: 'Failed to aggregate dashboard data',
            details: err.message,
        });
    }
});

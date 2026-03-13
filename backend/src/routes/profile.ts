import { Router } from 'express';
import { cache } from '../cache';
import { AuthRequest } from '../middleware/auth';

export const profileRouter = Router();

profileRouter.post('/cache-invalidate', async (req, res) => {
    try {
        const authReq = req as AuthRequest;
        const userId = authReq.user?.id;
        
        if (!userId) {
             res.status(401).json({ error: 'Unauthorized: Missing user ID' });
             return;
        }

        // Invalidate all relevant cache keys for this user
        cache.invalidate('github_stats_' + userId);
        cache.invalidate('leetcode_stats_' + userId);
        cache.invalidate('wakatime_stats_' + userId);
        cache.invalidate('dashboard_' + userId);

        res.json({ message: 'Cache invalidated successfully' });
    } catch (err: any) {
        console.error('Cache invalidation error?', err.message);
        res.status(500).json({
            error: 'Failed to invalidate cache',
            details: err.message,
        });
    }
});

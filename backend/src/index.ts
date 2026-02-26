import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { githubRouter } from './routes/github';
import { leetcodeRouter } from './routes/leetcode';
import { wakatimeRouter } from './routes/wakatime';
import { dashboardRouter } from './routes/dashboard';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/api/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

import { requireAuth } from './middleware/auth';

// API Routes
app.use('/api/github', requireAuth, githubRouter);
app.use('/api/leetcode', requireAuth, leetcodeRouter);
app.use('/api/wakatime', requireAuth, wakatimeRouter);
app.use('/api/dashboard', requireAuth, dashboardRouter);

// Error handler
app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
    console.error('Server error:', err.message);
    res.status(500).json({ error: err.message });
});

app.listen(PORT, () => {
    console.log(`🚀 DevPulse Backend running on http://localhost:${PORT}`);
    console.log(`   GitHub user: ${process.env.GITHUB_USERNAME}`);
    console.log(`   LeetCode user: ${process.env.LEETCODE_USERNAME}`);
    console.log(`   WakaTime: ${process.env.WAKATIME_API_KEY ? 'configured' : 'NOT configured'}`);
});

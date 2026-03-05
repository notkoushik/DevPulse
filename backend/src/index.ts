import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { githubRouter } from './routes/github';
import { leetcodeRouter } from './routes/leetcode';
import { wakatimeRouter } from './routes/wakatime';
import { dashboardRouter } from './routes/dashboard';
import { newsRouter } from './routes/news';
import { geminiRouter } from './routes/gemini';
import { chatRouter } from './routes/chat';
import { validateEnv, checkSupabaseConnectivity } from './config';
import { healthRouter } from './routes/health';

dotenv.config({ override: true });
const config = validateEnv();

const app = express();
const PORT = config.port;

// Middleware
app.use(cors());
app.use(express.json());

// Health check (liveness probe)
app.get('/api/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Deep health check (connectivity probe, no auth)
app.use('/api/health', healthRouter);

import { requireAuth } from './middleware/auth';

// API Routes
app.use('/api/github', requireAuth, githubRouter);
app.use('/api/leetcode', requireAuth, leetcodeRouter);
app.use('/api/wakatime', requireAuth, wakatimeRouter);
app.use('/api/dashboard', requireAuth, dashboardRouter);
app.use('/api/news', requireAuth, newsRouter);
app.use('/api/ai', requireAuth, geminiRouter);
app.use('/api/ai', requireAuth, chatRouter);

// Error handler
app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
    console.error('Server error:', err.message);
    res.status(500).json({ error: err.message });
});

app.listen(PORT, async () => {
    console.log(`DevPulse Backend running on http://localhost:${PORT}`);
    console.log(`  GitHub user: ${process.env.GITHUB_USERNAME || '(not set)'}`);
    console.log(`  LeetCode user: ${process.env.LEETCODE_USERNAME || '(not set)'}`);
    console.log(`  WakaTime: ${process.env.WAKATIME_API_KEY ? 'configured' : 'NOT configured'}`);
    console.log(`  Gemini AI: ${process.env.GEMINI_API_KEY ? 'configured' : 'NOT configured'}`);
    console.log(`  Gemini model: ${process.env.GEMINI_MODEL || 'gemini-2.0-flash (default)'}`);

    // Startup connectivity check
    console.log('  Checking Supabase connectivity...');
    const supaCheck = await checkSupabaseConnectivity();
    if (supaCheck.ok) {
        console.log(`  Supabase: connected (${supaCheck.latencyMs}ms)`);
    } else {
        console.error(`  Supabase: FAILED - ${supaCheck.error} (${supaCheck.latencyMs}ms)`);
        console.error('  WARNING: Auth will not work until Supabase is reachable.');
    }
});

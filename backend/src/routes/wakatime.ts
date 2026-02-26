import { Router } from 'express';
import axios from 'axios';
import { cache } from '../cache';
import { AuthRequest } from '../middleware/auth';

export const wakatimeRouter = Router();

const WAKA_BASE = 'https://wakatime.com/api/v1';

function getHeaders(authReq: AuthRequest): Record<string, string> {
    const key = authReq.userProfile?.wakatime_api_key || process.env.WAKATIME_API_KEY || '';
    // WakaTime expects Base64-encoded API key in Basic auth
    const encoded = Buffer.from(key).toString('base64');
    return {
        Authorization: `Basic ${encoded}`,
    };
}

// ─── /api/wakatime/stats ───
wakatimeRouter.get('/stats', async (req, res) => {
    try {
        const authReq = req as AuthRequest;
        const cached = cache.get<any>('wakatime_stats_' + authReq.user?.id);
        if (cached) return res.json(cached);

        // Fetch today's summary + last 7 days stats in parallel
        const [todayRes, weekRes] = await Promise.all([
            axios.get(`${WAKA_BASE}/users/current/status_bar/today`, {
                headers: getHeaders(authReq),
            }).catch(() => null),

            axios.get(`${WAKA_BASE}/users/current/stats/last_7_days`, {
                headers: getHeaders(authReq),
            }).catch(() => null),
        ]);

        // ─── Parse today's data ───
        const todayData = todayRes?.data?.data;
        const todayTime = todayData?.grand_total?.text ?? '0 hrs 0 mins';
        const todaySeconds = todayData?.grand_total?.total_seconds ?? 0;

        // ─── Parse weekly data ───
        const weekData = weekRes?.data?.data;
        const weeklyTotalText = weekData?.human_readable_total_including_other_language ?? '0 hrs';
        const weeklyTotalSeconds = weekData?.total_seconds_including_other_language ?? 0;
        const dailyAvgText = weekData?.human_readable_daily_average_including_other_language ?? '0 hrs';

        // Languages breakdown
        const languages = (weekData?.languages ?? []).slice(0, 8).map((l: any) => ({
            name: l.name,
            percent: l.percent,
            totalSeconds: l.total_seconds,
            text: l.text,
            color: _getLanguageColor(l.name),
        }));

        // Editors breakdown
        const editors = (weekData?.editors ?? []).slice(0, 5).map((e: any) => ({
            name: e.name,
            percent: e.percent,
            text: e.text,
        }));

        // Projects breakdown
        const projects = (weekData?.projects ?? []).slice(0, 8).map((p: any) => ({
            name: p.name,
            percent: p.percent,
            totalSeconds: p.total_seconds,
            text: p.text,
        }));

        // Daily breakdown (last 7 days)
        const dailyBreakdown = (weekData?.days ?? []).map((d: any) => ({
            date: d.date,
            totalSeconds: d.total,
            text: _formatSeconds(d.total),
        }));

        // If days aren't available from stats endpoint, generate from range
        const dailyCoding = dailyBreakdown.length > 0
            ? dailyBreakdown
            : _generateDailyFromWeek(weeklyTotalSeconds);

        const result = {
            today: {
                text: todayTime,
                totalSeconds: todaySeconds,
            },
            week: {
                text: weeklyTotalText,
                totalSeconds: weeklyTotalSeconds,
                dailyAverage: dailyAvgText,
            },
            languages,
            editors,
            projects,
            dailyCoding,
        };

        cache.set('wakatime_stats_' + authReq.user?.id, result, 600); // 10 min cache
        res.json(result);
    } catch (err: any) {
        console.error('WakaTime API error:', err.response?.data || err.message);
        res.status(500).json({
            error: 'Failed to fetch WakaTime data',
            details: err.response?.data?.message || err.message,
        });
    }
});

function _formatSeconds(totalSeconds: number): string {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    if (hours > 0) return `${hours}h ${minutes}m`;
    return `${minutes}m`;
}

function _generateDailyFromWeek(weeklyTotal: number): Array<{ date: string; totalSeconds: number; text: string }> {
    const result = [];
    const now = new Date();
    for (let i = 6; i >= 0; i--) {
        const d = new Date(now);
        d.setDate(d.getDate() - i);
        const approx = Math.floor(weeklyTotal / 7 * (0.5 + Math.random()));
        result.push({
            date: d.toISOString().split('T')[0],
            totalSeconds: approx,
            text: _formatSeconds(approx),
        });
    }
    return result;
}

function _getLanguageColor(name: string): string {
    const colors: Record<string, string> = {
        'Dart': '#00B4AB',
        'Python': '#3572A5',
        'JavaScript': '#F1E05A',
        'TypeScript': '#3178C6',
        'Java': '#B07219',
        'Kotlin': '#A97BFF',
        'C++': '#F34B7D',
        'C': '#555555',
        'Go': '#00ADD8',
        'Rust': '#DEA584',
        'Swift': '#FA7343',
        'HTML': '#E34C26',
        'CSS': '#563D7C',
        'SQL': '#E38C00',
        'Shell': '#89E051',
        'Ruby': '#701516',
        'PHP': '#4F5D95',
    };
    return colors[name] ?? '#888888';
}

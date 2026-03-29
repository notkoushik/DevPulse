import { Router } from 'express';
import { cache } from '../cache';
import { AuthRequest } from '../middleware/auth';
import { generateContent } from '../utils/ai';

export const geminiRouter = Router();

// ─── POST /api/ai/insights ───
geminiRouter.post('/insights', async (req, res) => {
  try {
    const authReq = req as AuthRequest;
    const userId = authReq.user?.id || 'anon';
    const { context, stats } = req.body;

    if (!context || !stats) {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'context and stats fields are required',
      });
    }

    const cacheKey = `ai_insights_${userId}_${context}`;
    const cached = cache.get<any>(cacheKey);
    if (cached) return res.json(cached);

    const prompt = `You are DevPulse AI, a concise developer productivity analyst embedded in a mobile dashboard app. Given the user's developer statistics, generate 1-3 short, actionable insight cards. Each insight must be:
- Under 120 characters
- Specific to the data provided (reference actual numbers)
- Categorized as one of: tip, warning, achievement, streak, suggestion
- Encouraging but honest

Crucially, if the stats include "streak", one of your insights must be of type "streak" and accurately state "Great job on your X-day streak!" where X is exactly the number provided for "streak".

Return ONLY valid JSON with no markdown formatting: { "insights": [{ "text": "...", "type": "..." }] }

User's ${context} stats:
${JSON.stringify(stats)}`;

    const text = await generateContent(prompt, true);

    let parsed;
    try {
      const cleaned = text.replace(/```json\n?/gi, '').replace(/```\n?/g, '').trim();
      parsed = JSON.parse(cleaned);
    } catch {
      parsed = { insights: [{ text: 'Keep coding and stay consistent!', type: 'tip' }] };
    }

    cache.set(cacheKey, parsed, 1800); // 30 min
    res.json(parsed);
  } catch (err: any) {
    console.error('Gemini insights error:', err.message);
    res.status(500).json({
      error: 'AI insights unavailable',
      message: err.message,
    });
  }
});

// ─── POST /api/ai/summary ───
geminiRouter.post('/summary', async (req, res) => {
  try {
    const authReq = req as AuthRequest;
    const userId = authReq.user?.id || 'anon';
    const { context, stats } = req.body;

    if (!context || !stats) {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'context and stats fields are required',
      });
    }

    const cacheKey = `ai_summary_${userId}_${context}`;
    const cached = cache.get<any>(cacheKey);
    if (cached) return res.json(cached);

    const prompt = `You are DevPulse AI. Given the user's ${context} developer stats, write a 1-2 sentence personalized summary. Be specific with numbers. Be encouraging but honest. Keep it under 200 characters.

Return ONLY valid JSON with no markdown: { "summary": "..." }

Stats:
${JSON.stringify(stats)}`;

    const text = await generateContent(prompt, true);

    let parsed;
    try {
      const cleaned = text.replace(/```json\n?/gi, '').replace(/```\n?/g, '').trim();
      parsed = JSON.parse(cleaned);
    } catch {
      parsed = { summary: 'Your developer activity is being tracked. Keep up the good work!' };
    }

    cache.set(cacheKey, parsed, 1800);
    res.json(parsed);
  } catch (err: any) {
    console.error('Gemini summary error:', err.message);
    res.status(500).json({
      error: 'AI summary unavailable',
      message: err.message,
    });
  }
});

// ─── POST /api/ai/recommendations ───
geminiRouter.post('/recommendations', async (req, res) => {
  try {
    const authReq = req as AuthRequest;
    const userId = authReq.user?.id || 'anon';
    const { stats } = req.body;

    const cacheKey = `ai_recs_${userId}`;
    const cached = cache.get<any>(cacheKey);
    if (cached) return res.json(cached);

    const prompt = `You are DevPulse AI. Based on the developer's stats, suggest 2-3 specific daily goals they should set. Each goal should be actionable (something to do today/this week).

Return ONLY valid JSON with no markdown: { "recommendations": [{ "type": "goal", "text": "..." }] }

Stats:
${JSON.stringify(stats)}`;

    const text = await generateContent(prompt, true);

    let parsed;
    try {
      const cleaned = text.replace(/```json\n?/gi, '').replace(/```\n?/g, '').trim();
      parsed = JSON.parse(cleaned);
    } catch {
      parsed = { recommendations: [{ type: 'goal', text: 'Solve 1 LeetCode problem today' }] };
    }

    cache.set(cacheKey, parsed, 1800);
    res.json(parsed);
  } catch (err: any) {
    console.error('Gemini recommendations error:', err.message);
    res.status(500).json({
      error: 'AI recommendations unavailable',
      message: err.message,
    });
  }
});

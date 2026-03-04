import { Router } from 'express';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { AuthRequest } from '../middleware/auth';

export const chatRouter = Router();

const GEMINI_MODEL = process.env.GEMINI_MODEL?.trim() || 'gemini-2.0-flash';

function getGenAI(): GoogleGenerativeAI | null {
  const key = process.env.GEMINI_API_KEY?.trim();
  if (!key) return null;
  return new GoogleGenerativeAI(key);
}

// ─── POST /api/ai/chat ───
chatRouter.post('/chat', async (req, res) => {
  try {
    const genAI = getGenAI();
    if (!genAI) {
      return res.status(503).json({ error: 'Gemini API key not configured' });
    }

    const { message, history, context } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Missing message' });
    }

    const model = genAI.getGenerativeModel({ model: GEMINI_MODEL });

    // Build system context from user stats
    let statsContext = '';
    if (context) {
      if (context.github) {
        const g = context.github;
        statsContext += `\nGitHub: ${g.todayCommits || 0} commits today, streak: ${g.streak || 0} days, ${g.totalRepos || 0} repos, ${g.totalStars || 0} stars.`;
      }
      if (context.leetcode) {
        const l = context.leetcode;
        statsContext += `\nLeetCode: ${l.totalSolved || 0}/${l.totalQuestions || 0} solved, ranking: ${l.ranking || 'N/A'}, acceptance: ${l.acceptanceRate || 0}%.`;
      }
      if (context.goals) {
        const goals = context.goals;
        const completed = Array.isArray(goals) ? goals.filter((g: any) => g.completed).length : 0;
        const total = Array.isArray(goals) ? goals.length : 0;
        statsContext += `\nGoals: ${completed}/${total} completed today.`;
      }
    }

    const systemPrompt = `You are DevPulse AI Assistant, a friendly developer coach who helps users understand and improve their coding habits. You have access to the user's real-time stats:
${statsContext}

Guidelines:
- Keep answers concise (under 200 words unless the user asks for detail)
- Reference the user's actual data when relevant
- Suggest specific, actionable improvements
- Be encouraging but realistic
- If asked about something outside developer productivity, politely redirect`;

    // Build chat history
    const chatHistory = (history || []).map((h: any) => ({
      role: h.role === 'user' ? 'user' : 'model',
      parts: [{ text: h.content }],
    }));

    const chat = model.startChat({
      history: [
        { role: 'user', parts: [{ text: systemPrompt }] },
        { role: 'model', parts: [{ text: 'Understood! I\'m DevPulse AI, ready to help you improve your developer productivity. What would you like to know?' }] },
        ...chatHistory,
      ],
    });

    const result = await chat.sendMessage(message);
    const reply = result.response.text().trim();

    res.json({ reply });
  } catch (err: any) {
    console.error('Gemini chat error:', err.message);
    res.status(500).json({ error: 'AI chat unavailable' });
  }
});

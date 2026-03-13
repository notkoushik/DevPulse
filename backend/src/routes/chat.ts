import { Router } from 'express';
import { AuthRequest } from '../middleware/auth';
import { generateChat, ChatMessage } from '../utils/ai';

export const chatRouter = Router();

// ─── POST /api/ai/chat ───
chatRouter.post('/chat', async (req, res) => {
  try {
    const { message, history, context } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Missing message' });
    }

    // Build system context from user stats
    let statsContext = '';
    if (context) {
      if (context.github) {
        const g = context.github;
        const ghUser = g.username ? `@${g.username}` : 'their GitHub account';
        statsContext += `\nGitHub (${ghUser}): ${g.todayCommits || 0} commits today, streak: ${g.streak || 0} days, ${g.totalRepos || 0} repos, ${g.totalStars || 0} stars.`;
      }
      if (context.leetcode) {
        const l = context.leetcode;
        const lcUser = l.username ? `@${l.username}` : 'their LeetCode account';
        statsContext += `\nLeetCode (${lcUser}): ${l.totalSolved || 0}/${l.totalQuestions || 0} solved, ranking: ${l.ranking || 'N/A'}, acceptance: ${l.acceptanceRate || 0}%.`;
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

    // Construct full message history Array
    const messages: ChatMessage[] = [];
    messages.push({ role: 'system', content: systemPrompt });

    if (history && Array.isArray(history)) {
      history.forEach((h: any) => {
        messages.push({ role: h.role === 'user' ? 'user' : 'model', content: h.content });
      });
    }

    messages.push({ role: 'user', content: message });

    const reply = await generateChat(messages);
    res.json({ reply });
  } catch (err: any) {
    console.error('AI chat error:', err.message);
    res.status(500).json({ error: 'AI chat unavailable' });
  }
});

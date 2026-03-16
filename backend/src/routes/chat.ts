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

    const githubUser = context?.github?.username ? `@${context.github.username}` : null;
    const lcUser = context?.leetcode?.username ? `@${context.leetcode.username}` : null;
    const userLine = [githubUser && `GitHub: ${githubUser}`, lcUser && `LeetCode: ${lcUser}`]
      .filter(Boolean).join(', ');

    const systemPrompt = `You are DevPulse AI, a personal developer productivity coach. ${userLine ? `You are talking to the developer whose accounts are: ${userLine}.` : ''}
You have access to their LIVE stats right now:
${statsContext}

Guidelines:
- Address the user naturally, referencing their actual username when it feels relevant
- Keep answers concise (under 200 words unless the user asks for detail)
- Reference the user's actual numbers when they ask about progress
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

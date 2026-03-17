import request from 'supertest';
import express from 'express';
import { chatRouter } from '../../routes/chat';
import * as aiTools from '../../utils/ai';
import { cache } from '../../cache';

// Mock utils/ai
jest.mock('../../utils/ai', () => ({
    generateChat: jest.fn(),
}));

const app = express();
app.use(express.json());

// Mock Auth wrapper
app.use((req: any, res, next) => {
    req.user = { id: 'user123' };
    next();
});

app.use('/', chatRouter);

describe('chatRouter', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        cache.clear();
    });

    it('should reject requests without a message', async () => {
        const res = await request(app)
            .post('/chat')
            .send({}); // missing message

        expect(res.status).toBe(400);
        expect(res.body.error).toBe('Missing message');
    });

    it('should build context correctly from context body and call generateChat', async () => {
        (aiTools.generateChat as jest.Mock).mockResolvedValue('Hello from AI');

        const context = {
            github: { todayCommits: 50, streak: 7, totalRepos: 20, totalStars: 100 },
            leetcode: { totalSolved: 10, totalQuestions: 2500, ranking: 50000, acceptanceRate: 60 },
        };

        const history = [
            { role: 'user', content: 'Hi' },
            { role: 'model', content: 'Hello' }
        ];

        const res = await request(app)
            .post('/chat')
            .send({
                message: 'How is my progress?',
                history,
                context,
            });

        expect(res.status).toBe(200);
        expect(res.body.reply).toBe('Hello from AI');

        expect(aiTools.generateChat).toHaveBeenCalledTimes(1);
        const callArgs = (aiTools.generateChat as jest.Mock).mock.calls[0];

        // generateChat receives a single ChatMessage[] array
        const messages: Array<{ role: string; content: string }> = callArgs[0];
        expect(Array.isArray(messages)).toBe(true);

        // First element is the system prompt message
        const systemMessage = messages.find((m) => m.role === 'system');
        expect(systemMessage).toBeDefined();
        expect(systemMessage!.content).toContain('You are DevPulse AI');
        expect(systemMessage!.content).toContain('50 commits today');
        expect(systemMessage!.content).toContain('10/2500 solved');

        // History turns are embedded inside the messages array
        const hiTurn = messages.find((m) => m.role === 'user' && m.content === 'Hi');
        expect(hiTurn).toBeDefined();
    });

    it('should handle AI model failures gracefully', async () => {
        (aiTools.generateChat as jest.Mock).mockRejectedValue(new Error('AI Service Down'));

        const res = await request(app)
            .post('/chat')
            .send({ message: 'Hello' });

        expect(res.status).toBe(500);
        expect(res.body.error).toBe('AI chat unavailable');
    });
});

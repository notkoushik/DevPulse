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

    it('should build context correctly from cache and call generateChat', async () => {
        (aiTools.generateChat as jest.Mock).mockResolvedValue('Hello from AI');

        // Pre-warm caches to verify context building
        cache.set('dashboard_user123', {
            github: { user: { totalCommits: 50 }, stats: { recentRepos: [] } },
            leetcode: { totalSolved: 10, easy: { solved: 5 }, medium: { solved: 4 }, hard: { solved: 1 } },
        });

        // Mock a user profile fetch (we bypassed auth so just pretend req.userProfile is there)
        app.use((req: any, res, next) => {
            req.userProfile = { goal: 'Get a FAANG job' };
            next();
        });

        const history = [
            { role: 'user', content: 'Hi' },
            { role: 'model', content: 'Hello' }
        ];

        const res = await request(app)
            .post('/chat')
            .send({
                message: 'How is my progress?',
                history
            });

        expect(res.status).toBe(200);
        expect(res.body.reply).toBe('Hello from AI');

        // Verify that generateChat was called with the context string
        expect(aiTools.generateChat).toHaveBeenCalledTimes(1);
        const callArgs = (aiTools.generateChat as jest.Mock).mock.calls[0];
        const systemPrompt = callArgs[0];
        
        expect(systemPrompt).toContain('You are an AI assistant');
        expect(systemPrompt).toContain('totalCommits: 50');
        expect(systemPrompt).toContain('totalSolved: 10');

        // Verify history was passed
        expect(callArgs[2]).toEqual(history);
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

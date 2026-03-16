import request from 'supertest';
import express from 'express';
import { healthRouter } from '../../routes/health';
import * as config from '../../config';

// Mock config module functions
jest.mock('../../config', () => ({
    getEnvStatus: jest.fn(),
    checkSupabaseConnectivity: jest.fn(),
    checkGitHubConnectivity: jest.fn(),
}));

const app = express();
app.use('/', healthRouter);

describe('healthRouter', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    describe('/deep', () => {
        it('should return 200 healthy when both services are up', async () => {
            (config.checkSupabaseConnectivity as jest.Mock).mockResolvedValue({ ok: true, latencyMs: 50 });
            (config.checkGitHubConnectivity as jest.Mock).mockResolvedValue({ ok: true, latencyMs: 120 });
            (config.getEnvStatus as jest.Mock).mockReturnValue({ SUPABASE_URL: true });

            const res = await request(app).get('/deep');
            expect(res.status).toBe(200);
            expect(res.body.status).toBe('healthy');
            expect(res.body.services.supabase.status).toBe('pass');
            expect(res.body.services.github.status).toBe('pass');
        });

        it('should return 200 degraded when GitHub is down but DB is up', async () => {
            (config.checkSupabaseConnectivity as jest.Mock).mockResolvedValue({ ok: true, latencyMs: 50 });
            (config.checkGitHubConnectivity as jest.Mock).mockResolvedValue({ ok: false, error: 'Timeout', latencyMs: 5000 });
            (config.getEnvStatus as jest.Mock).mockReturnValue({ GITHUB_PAT: false });

            const res = await request(app).get('/deep');
            expect(res.status).toBe(200);
            expect(res.body.status).toBe('degraded');
            expect(res.body.services.supabase.status).toBe('pass');
            expect(res.body.services.github.status).toBe('fail');
            expect(res.body.services.github.error).toBe('Timeout');
        });

        it('should return 503 unhealthy when Supabase DB is down', async () => {
            (config.checkSupabaseConnectivity as jest.Mock).mockResolvedValue({ ok: false, error: 'Connection refused' });
            (config.checkGitHubConnectivity as jest.Mock).mockResolvedValue({ ok: true });
            
            const res = await request(app).get('/deep');
            expect(res.status).toBe(503);
            expect(res.body.status).toBe('unhealthy');
            expect(res.body.services.supabase.status).toBe('fail');
            expect(res.body.services.supabase.error).toBe('Connection refused');
            // GitHub could still be 'up', but overall is unhealthy
            expect(res.body.services.github.status).toBe('pass');
        });
    });
});

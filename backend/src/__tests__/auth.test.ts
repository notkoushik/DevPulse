import request from 'supertest';
import express, { Request, Response } from 'express';
import { requireAuth, AuthRequest, supabase } from '../middleware/auth';
import { cache } from '../cache';

// Mock Supabase
jest.mock('@supabase/supabase-js', () => {
    return {
        createClient: jest.fn(() => ({
            auth: {
                getUser: jest.fn(),
            },
            from: jest.fn().mockReturnThis(),
            select: jest.fn().mockReturnThis(),
            eq: jest.fn().mockReturnThis(),
            single: jest.fn(),
        })),
    };
});

// Setup minimal Express app for testing middleware
const app = express();
app.use(express.json());

app.get('/protected', requireAuth, (req: AuthRequest, res: Response) => {
    res.json({
        message: 'Success',
        user: req.user,
        profile: req.userProfile
    });
});

describe('requireAuth Middleware', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        cache.clear(); // Clear our new auth cache before each test
    });

    it('should reject requests without authorization header', async () => {
        const res = await request(app).get('/protected');
        expect(res.status).toBe(401);
        expect(res.body.error).toBe('Missing or invalid authorization header');
    });

    it('should reject requests with invalid authorization format', async () => {
        const res = await request(app).get('/protected').set('Authorization', 'InvalidFormat');
        expect(res.status).toBe(401);
        expect(res.body.error).toBe('Missing or invalid authorization header');
    });

    it('should reject invalid tokens (Supabase getUser fails)', async () => {
        // Mock token verification failure
        (supabase.auth.getUser as jest.Mock).mockResolvedValueOnce({
            data: { user: null },
            error: { message: 'jwt expired' },
        });

        const res = await request(app)
            .get('/protected')
            .set('Authorization', 'Bearer expired-token');

        expect(res.status).toBe(401);
        expect(res.body.error).toBe('Unauthorized: Invalid token');
        expect(supabase.auth.getUser).toHaveBeenCalledWith('expired-token');
    });

    it('should allow valid tokens and fetch profile on cache miss', async () => {
        // Mock successful verify
        const mockUser = { id: 'user-123', email: 'test@example.com' };
        (supabase.auth.getUser as jest.Mock).mockResolvedValueOnce({
            data: { user: mockUser },
            error: null,
        });

        // Mock profile fetch
        const mockProfile = { github_username: 'gh_user', leetcode_username: 'lc_user' };
        
        const mockSingle = jest.fn().mockResolvedValueOnce({
            data: mockProfile,
            error: null,
        });
        const mockEq = jest.fn().mockReturnValue({ single: mockSingle });
        const mockSelect = jest.fn().mockReturnValue({ eq: mockEq });
        (supabase.from as jest.Mock).mockReturnValue({ select: mockSelect });

        const res = await request(app)
            .get('/protected')
            .set('Authorization', 'Bearer valid-token-1234567890123456');

        expect(res.status).toBe(200);
        expect(res.body.user).toEqual(mockUser);
        expect(res.body.profile).toEqual(mockProfile);

        // Should have called Supabase
        expect(supabase.auth.getUser).toHaveBeenCalledTimes(1);
        expect(mockEq).toHaveBeenCalledWith('id', 'user-123');

        // Verify it was cached (key uses last 16 chars of token)
        expect(cache.size).toBe(1);
    });

    it('should skip Supabase calls on cache hit (Phase 1 Fix)', async () => {
        const token = 'valid-token-1234567890123456';
        const cacheKey = `auth_${token.substring(token.length - 16)}`;
        
        // Pre-warm cache
        const mockUser = { id: 'cached-user' };
        const mockProfile = { github_username: 'cached_gh' };
        cache.set(cacheKey, { user: mockUser, profile: mockProfile });

        const res = await request(app)
            .get('/protected')
            .set('Authorization', `Bearer ${token}`);

        expect(res.status).toBe(200);
        expect(res.body.user).toEqual(mockUser);
        expect(res.body.profile).toEqual(mockProfile);

        // MOST IMPORTANT: Supabase should NOT be called at all
        expect(supabase.auth.getUser).not.toHaveBeenCalled();
        expect((supabase.from('profiles').select as any)().eq).not.toHaveBeenCalled();
    });

    it('should handle missing profiles gracefully', async () => {
        const mockUser = { id: 'user-123' };
        (supabase.auth.getUser as jest.Mock).mockResolvedValueOnce({
            data: { user: mockUser },
            error: null,
        });

        // Simulate no profile row (PGRST116)
        const mockSingleError = jest.fn().mockResolvedValueOnce({
            data: null,
            error: { code: 'PGRST116', message: 'No rows' },
        });
        const mockEqError = jest.fn().mockReturnValue({ single: mockSingleError });
        const mockSelectError = jest.fn().mockReturnValue({ eq: mockEqError });
        (supabase.from as jest.Mock).mockReturnValue({ select: mockSelectError });

        const res = await request(app)
            .get('/protected')
            .set('Authorization', 'Bearer another-token');

        expect(res.status).toBe(200);
        expect(res.body.user).toEqual(mockUser);
        expect(res.body.profile).toEqual({}); // Empty object fallback
    });
});

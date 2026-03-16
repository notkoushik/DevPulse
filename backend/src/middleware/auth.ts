import { Request, Response, NextFunction } from 'express';
import { createClient } from '@supabase/supabase-js';
import { cache } from '../cache';
import dotenv from 'dotenv';
dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL || '';
const supabaseKey = process.env.SUPABASE_SECRET_KEY || process.env.SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseKey);

export interface AuthRequest extends Request {
    user?: any;
    userProfile?: {
        github_username?: string;
        leetcode_username?: string;
        wakatime_api_key?: string;
    };
}

/**
 * Auth cache: stores verified {user, profile} per token for 60 seconds.
 * This eliminates 2 Supabase API calls per request for active sessions,
 * reducing free-tier consumption from ~46 req/min to virtually unlimited
 * for repeat requests within the cache window.
 */
const AUTH_CACHE_TTL = 60; // seconds

interface CachedAuth {
    user: any;
    profile: any;
}

export const requireAuth = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            res.status(401).json({ error: 'Missing or invalid authorization header' });
            return;
        }

        const token = authHeader.split(' ')[1];

        // ── Cache check: skip Supabase calls if token was recently verified ──
        const cacheKey = `auth_${token.substring(token.length - 16)}`; // Use last 16 chars as key (safe, not the full token)
        const cached = cache.get<CachedAuth>(cacheKey);

        if (cached) {
            req.user = cached.user;
            req.userProfile = cached.profile;
            return next();
        }

        // ── Cache miss: verify with Supabase ──
        const { data: { user }, error } = await supabase.auth.getUser(token);

        if (error || !user) {
            console.warn('Auth token verification failed:', {
                errorMessage: error?.message,
                errorStatus: error?.status,
                hasUser: !!user,
            });
            res.status(401).json({ error: 'Unauthorized: Invalid token' });
            return;
        }

        req.user = user;

        // Fetch user profile from public.profiles table
        const { data: profile, error: profileError } = await supabase
            .from('profiles')
            .select('github_username, leetcode_username, wakatime_api_key')
            .eq('id', user.id)
            .single();

        if (profileError && profileError.code !== 'PGRST116') { // PGRST116 = no rows returned
            console.error('Error fetching profile:', profileError);
        }

        const resolvedProfile = profile || {};
        req.userProfile = resolvedProfile;

        // ── Cache the verified auth result ──
        cache.set<CachedAuth>(cacheKey, { user, profile: resolvedProfile }, AUTH_CACHE_TTL);

        next();
    } catch (err: any) {
        console.error('Auth error:', {
            message: err?.message,
            code: err?.code,
            status: err?.status,
            stack: err?.stack,
        });
        res.status(500).json({ error: 'Internal server error during authentication' });
        return;
    }
};

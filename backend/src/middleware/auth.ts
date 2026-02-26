import { Request, Response, NextFunction } from 'express';
import { createClient } from '@supabase/supabase-js';
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

export const requireAuth = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            res.status(401).json({ error: 'Missing or invalid authorization header' });
            return;
        }

        const token = authHeader.split(' ')[1];

        // Verify the JWT with Supabase using getUser for true verification
        const { data: { user }, error } = await supabase.auth.getUser(token);

        if (error || !user) {
            res.status(401).json({ error: 'Unauthorized: Invalid token' });
            return;
        }

        req.user = user;

        // Fetch user profile from public.profiles table
        // (Assuming a table named profiles exists with these columns)
        const { data: profile, error: profileError } = await supabase
            .from('profiles')
            .select('github_username, leetcode_username, wakatime_api_key')
            .eq('id', user.id)
            .single();

        if (profileError && profileError.code !== 'PGRST116') { // PGRST116 = no rows returned
            console.error('Error fetching profile:', profileError);
        }

        req.userProfile = profile || {};

        next();
    } catch (err) {
        console.error('Auth error:', err);
        res.status(500).json({ error: 'Internal server error during authentication' });
        return;
    }
};

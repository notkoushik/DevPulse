import { supabase } from './middleware/auth';
import axios from 'axios';

// --- Types ---

interface EnvConfig {
  supabaseUrl: string;
  supabaseKey: string;
  port: number;
  githubPat: string;
  githubUsername: string;
  leetcodeUsername: string;
  wakatimeApiKey: string;
  geminiApiKey: string;
  geminiModel: string;
}

// --- Exported functions ---

/**
 * Validates critical env vars, logs warnings for optional ones,
 * and returns a frozen config object.
 * Calls process.exit(1) if critical vars are missing.
 */
export function validateEnv(): EnvConfig {
  const missing: string[] = [];

  const supabaseUrl = process.env.SUPABASE_URL?.trim() || '';
  if (!supabaseUrl) missing.push('SUPABASE_URL');

  const supabaseKey = (
    process.env.SUPABASE_SECRET_KEY?.trim() ||
    process.env.SUPABASE_ANON_KEY?.trim() ||
    ''
  );
  if (!supabaseKey) missing.push('SUPABASE_SECRET_KEY or SUPABASE_ANON_KEY');

  if (missing.length > 0) {
    console.error('FATAL: Missing critical environment variables:');
    missing.forEach((v) => console.error(`  - ${v}`));
    console.error('Server cannot start. Check your .env file.');
    process.exit(1);
  }

  const optional: Array<[string, string]> = [
    ['GITHUB_PAT', 'GitHub API calls will fail'],
    ['GITHUB_USERNAME', 'GitHub defaults to hardcoded username'],
    ['LEETCODE_USERNAME', 'LeetCode defaults to hardcoded username'],
    ['WAKATIME_API_KEY', 'WakaTime API calls will fail'],
    ['GEMINI_API_KEY', 'AI features will be disabled'],
  ];

  for (const [varName, consequence] of optional) {
    if (!process.env[varName]?.trim()) {
      console.warn(`WARNING: ${varName} is not set -- ${consequence}`);
    }
  }

  return Object.freeze({
    supabaseUrl,
    supabaseKey,
    port: parseInt(process.env.PORT || '3001', 10) || 3001,
    githubPat: process.env.GITHUB_PAT?.trim() || '',
    githubUsername: process.env.GITHUB_USERNAME?.trim() || '',
    leetcodeUsername: process.env.LEETCODE_USERNAME?.trim() || '',
    wakatimeApiKey: process.env.WAKATIME_API_KEY?.trim() || '',
    geminiApiKey: process.env.GEMINI_API_KEY?.trim() || '',
    geminiModel: process.env.GEMINI_MODEL?.trim() || 'gemini-2.0-flash',
  });
}

/**
 * Returns boolean presence map for all env vars.
 * Safe to include in API responses -- never leaks actual values.
 */
export function getEnvStatus(): Record<string, boolean> {
  return {
    SUPABASE_URL: !!process.env.SUPABASE_URL?.trim(),
    SUPABASE_SECRET_KEY: !!process.env.SUPABASE_SECRET_KEY?.trim(),
    SUPABASE_ANON_KEY: !!process.env.SUPABASE_ANON_KEY?.trim(),
    GITHUB_PAT: !!process.env.GITHUB_PAT?.trim(),
    GITHUB_USERNAME: !!process.env.GITHUB_USERNAME?.trim(),
    LEETCODE_USERNAME: !!process.env.LEETCODE_USERNAME?.trim(),
    WAKATIME_API_KEY: !!process.env.WAKATIME_API_KEY?.trim(),
    GEMINI_API_KEY: !!process.env.GEMINI_API_KEY?.trim(),
    GEMINI_MODEL: !!process.env.GEMINI_MODEL?.trim(),
  };
}

/**
 * Pings Supabase by running a lightweight query.
 */
export async function checkSupabaseConnectivity(): Promise<{
  ok: boolean;
  latencyMs: number;
  error?: string;
}> {
  const start = Date.now();
  try {
    const { error } = await supabase
      .from('profiles')
      .select('id', { count: 'exact', head: true })
      .limit(0);

    const latencyMs = Date.now() - start;

    if (error) {
      // PGRST errors mean Supabase responded (DB is reachable) but query had issues
      const isReachable = error.code?.startsWith('PGRST') || false;
      return {
        ok: isReachable,
        latencyMs,
        error: isReachable
          ? `Supabase reachable but query issue: ${error.message}`
          : error.message,
      };
    }
    return { ok: true, latencyMs };
  } catch (err: any) {
    return {
      ok: false,
      latencyMs: Date.now() - start,
      error: err.message || 'Unknown error',
    };
  }
}

/**
 * Pings GitHub REST API (GET /rate_limit).
 */
export async function checkGitHubConnectivity(): Promise<{
  ok: boolean;
  latencyMs: number;
  error?: string;
}> {
  const start = Date.now();
  try {
    const headers: Record<string, string> = {
      'Accept': 'application/vnd.github.v3+json',
    };
    const pat = process.env.GITHUB_PAT?.trim();
    if (pat) {
      headers['Authorization'] = `Bearer ${pat}`;
    }

    const response = await axios.get('https://api.github.com/rate_limit', {
      headers,
      timeout: 5000,
    });

    const latencyMs = Date.now() - start;
    return { ok: response.status === 200, latencyMs };
  } catch (err: any) {
    return {
      ok: false,
      latencyMs: Date.now() - start,
      error: err.response?.status
        ? `HTTP ${err.response.status}: ${err.response.data?.message || 'Unknown'}`
        : err.message || 'Network error',
    };
  }
}

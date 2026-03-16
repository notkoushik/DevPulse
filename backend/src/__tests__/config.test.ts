import { validateEnv, getEnvStatus, checkSupabaseConnectivity, checkGitHubConnectivity } from '../config';
import { supabase } from '../middleware/auth';
import axios from 'axios';

// Mock dependencies
jest.mock('../middleware/auth', () => ({
  supabase: {
    from: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    limit: jest.fn(),
  }
}));

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

describe('config.ts', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    jest.resetModules(); // clears the cache
    process.env = { ...originalEnv }; // Make a copy
  });

  afterAll(() => {
    process.env = originalEnv; // Restore
  });

  describe('validateEnv', () => {
    it('should throw an error and exit if SUPABASE_URL is missing', () => {
      delete process.env.SUPABASE_URL;
      process.env.SUPABASE_SECRET_KEY = 'test-key';
      
      const mockExit = jest.spyOn(process, 'exit').mockImplementation(() => {
        throw new Error('process.exit called');
      }) as unknown as jest.SpyInstance;
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});

      expect(() => {
        validateEnv();
      }).toThrow('process.exit called');

      expect(consoleErrorSpy).toHaveBeenCalledWith(expect.stringContaining('FATAL: Missing critical environment variables:'));
      
      mockExit.mockRestore();
      consoleErrorSpy.mockRestore();
    });

    it('should throw an error and exit if both Supabase keys are missing', () => {
      process.env.SUPABASE_URL = 'https://test.supabase.co';
      delete process.env.SUPABASE_SECRET_KEY;
      delete process.env.SUPABASE_ANON_KEY;
      
      const mockExit = jest.spyOn(process, 'exit').mockImplementation(() => {
        throw new Error('process.exit called');
      }) as unknown as jest.SpyInstance;
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});

      expect(() => {
        validateEnv();
      }).toThrow('process.exit called');

      mockExit.mockRestore();
      consoleErrorSpy.mockRestore();
    });

    it('should return a frozen config object when critical vars are present', () => {
      process.env.SUPABASE_URL = 'https://test.supabase.co';
      process.env.SUPABASE_SECRET_KEY = 'test-secret';
      process.env.PORT = '4000';
      process.env.GITHUB_PAT = 'ghp_test';
      process.env.GITHUB_USERNAME = 'testuser';

      const consoleWarnSpy = jest.spyOn(console, 'warn').mockImplementation(() => {});

      const config = validateEnv();

      expect(config.supabaseUrl).toBe('https://test.supabase.co');
      expect(config.supabaseKey).toBe('test-secret');
      expect(config.port).toBe(4000);
      expect(config.githubPat).toBe('ghp_test');
      expect(config.githubUsername).toBe('testuser');
      expect(Object.isFrozen(config)).toBe(true);

      consoleWarnSpy.mockRestore();
    });

    it('should use anon key if secret key is missing', () => {
      process.env.SUPABASE_URL = 'https://test.supabase.co';
      delete process.env.SUPABASE_SECRET_KEY;
      process.env.SUPABASE_ANON_KEY = 'test-anon';

      const consoleWarnSpy = jest.spyOn(console, 'warn').mockImplementation(() => {});

      const config = validateEnv();
      expect(config.supabaseKey).toBe('test-anon');

      consoleWarnSpy.mockRestore();
    });
  });

  describe('getEnvStatus', () => {
    it('should return true for present vars and false for missing ones', () => {
      process.env.SUPABASE_URL = 'https://test.supabase.co';
      delete process.env.GITHUB_PAT;

      const status = getEnvStatus();

      expect(status.SUPABASE_URL).toBe(true);
      expect(status.GITHUB_PAT).toBe(false);
      
      // Ensure values are booleans, not the actual secrets
      expect(typeof status.SUPABASE_URL).toBe('boolean');
    });
  });

  describe('checkSupabaseConnectivity', () => {
    it('should return ok:true on successful query', async () => {
      // Mock successful DB response
      (supabase.from('profiles').select('id', { count: 'exact', head: true }).limit as jest.Mock).mockResolvedValue({ error: null });

      const result = await checkSupabaseConnectivity();

      expect(result.ok).toBe(true);
      expect(typeof result.latencyMs).toBe('number');
      expect(result.error).toBeUndefined();
    });

    it('should return ok:true for reachable DB but query errors (PGRST)', async () => {
      // Mock Postgres error indicating DB is alive but query failed
      (supabase.from('profiles').select('id', { count: 'exact', head: true }).limit as jest.Mock).mockResolvedValue({ 
        error: { code: 'PGRST116', message: 'No rows' } 
      });

      const result = await checkSupabaseConnectivity();

      expect(result.ok).toBe(true); // DB is reachable
      expect(result.error).toContain('Supabase reachable but query issue');
    });

    it('should return ok:false for network errors', async () => {
      // Mock network error
      (supabase.from('profiles').select('id', { count: 'exact', head: true }).limit as jest.Mock).mockRejectedValue(new Error('Network error'));

      const result = await checkSupabaseConnectivity();

      expect(result.ok).toBe(false);
      expect(result.error).toBe('Network error');
    });
  });

  describe('checkGitHubConnectivity', () => {
    it('should return ok:true on successful API call', async () => {
      process.env.GITHUB_PAT = 'ghp_test';
      mockedAxios.get.mockResolvedValue({ status: 200 });

      const result = await checkGitHubConnectivity();

      expect(result.ok).toBe(true);
      expect(typeof result.latencyMs).toBe('number');
      expect(mockedAxios.get).toHaveBeenCalledWith('https://api.github.com/rate_limit', expect.objectContaining({
        headers: expect.objectContaining({
          'Authorization': 'Bearer ghp_test'
        })
      }));
    });

    it('should return ok:false on network errors', async () => {
      mockedAxios.get.mockRejectedValue(new Error('Network timeout'));

      const result = await checkGitHubConnectivity();

      expect(result.ok).toBe(false);
      expect(result.error).toBe('Network timeout');
    });

    it('should return ok:false with HTTP status if present', async () => {
      mockedAxios.get.mockRejectedValue({
        response: { status: 401, data: { message: 'Bad credentials' } }
      });

      const result = await checkGitHubConnectivity();

      expect(result.ok).toBe(false);
      expect(result.error).toBe('HTTP 401: Bad credentials');
    });
  });
});

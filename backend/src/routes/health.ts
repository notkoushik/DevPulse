import { Router, Request, Response } from 'express';
import {
  getEnvStatus,
  checkSupabaseConnectivity,
  checkGitHubConnectivity,
} from '../config';

export const healthRouter = Router();

interface ServiceCheck {
  status: 'pass' | 'fail';
  latencyMs: number;
  error?: string;
}

interface DeepHealthResponse {
  status: 'healthy' | 'degraded' | 'unhealthy';
  timestamp: string;
  services: {
    supabase: ServiceCheck;
    github: ServiceCheck;
  };
  env: Record<string, boolean>;
}

healthRouter.get('/deep', async (_req: Request, res: Response) => {
  const [supabaseResult, githubResult] = await Promise.all([
    checkSupabaseConnectivity(),
    checkGitHubConnectivity(),
  ]);

  const supabaseCheck: ServiceCheck = {
    status: supabaseResult.ok ? 'pass' : 'fail',
    latencyMs: supabaseResult.latencyMs,
    ...(supabaseResult.error && { error: supabaseResult.error }),
  };

  const githubCheck: ServiceCheck = {
    status: githubResult.ok ? 'pass' : 'fail',
    latencyMs: githubResult.latencyMs,
    ...(githubResult.error && { error: githubResult.error }),
  };

  // Status logic:
  // - healthy:   both pass
  // - degraded:  supabase passes but github fails (app can still auth users)
  // - unhealthy: supabase fails (auth is broken, app is non-functional)
  let status: DeepHealthResponse['status'];
  if (supabaseCheck.status === 'pass' && githubCheck.status === 'pass') {
    status = 'healthy';
  } else if (supabaseCheck.status === 'pass') {
    status = 'degraded';
  } else {
    status = 'unhealthy';
  }

  const response: DeepHealthResponse = {
    status,
    timestamp: new Date().toISOString(),
    services: {
      supabase: supabaseCheck,
      github: githubCheck,
    },
    env: getEnvStatus(),
  };

  // HTTP status: 200 for healthy/degraded, 503 for unhealthy
  const httpStatus = status === 'unhealthy' ? 503 : 200;
  res.status(httpStatus).json(response);
});

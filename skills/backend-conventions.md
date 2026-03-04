
---

### `skills/03-backend-conventions.md`

```markdown
# Backend Conventions

## Stack

- **Runtime:** Node.js 20+
- **Framework:** Express 4.x
- **Language:** TypeScript 5.7+ (strict mode)
- **Auth:** Supabase JWT verification
- **Cache:** In-memory `SimpleCache` (15 min TTL)

## Environment Variables

All defined in `backend/.env` (copy from `.env.example`):

| Variable | Required | Description |
|----------|----------|-------------|
| `GITHUB_PAT` | Yes | GitHub Personal Access Token (`read:user` + `repo` scopes) |
| `GITHUB_USERNAME` | No | Fallback GitHub username (used if profile has none) |
| `LEETCODE_USERNAME` | No | Fallback LeetCode username |
| `WAKATIME_API_KEY` | No | Fallback WakaTime API key |
| `PORT` | No | Server port (default: 3001) |
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Supabase anon/public key |
| `SUPABASE_SECRET_KEY` | Yes | Supabase service role key (for server-side auth) |

## Route Structure


GET /api/health → { status: "ok" } (no auth)
GET /api/github/stats → GitHub stats + user (auth required)
GET /api/leetcode/stats → LeetCode stats (auth required)
GET /api/wakatime/stats → WakaTime stats (auth required)
GET /api/dashboard → Aggregated all stats (auth required)


## Auth Middleware Flow

1. Extract `Authorization: Bearer <jwt>` header
2. Call `supabase.auth.getUser(token)` to verify JWT
3. Query `profiles` table for user's API keys/usernames
4. Attach to `req.user`: `{ id, email, github_username, leetcode_username, wakatime_api_key }`
5. If no profile field → fall back to env vars (e.g., `GITHUB_USERNAME`)

## Caching Rules

```typescript
// ✅ Always cache external API calls
const data = await cache.getOrFetch(
  `github:${username}`,     // key: namespace:identifier
  () => fetchFromGithub(),  // fetcher function
  15 * 60 * 1000            // TTL: 15 minutes
);

// ✅ Cache keys must be user-scoped
`github:${username}`        // Not just 'github'
`leetcode:${username}`
`wakatime:${userId}`


// ✅ Always return structured errors
res.status(500).json({ error: 'GitHub API failed', details: err.message });

// ❌ Never crash silently
catch (err) { /* do nothing */ }

// ❌ Never expose stack traces to client in production
res.status(500).json({ error: err.stack }); // WRONG


Code Style
Use async/await over .then() chains
Use TypeScript strict mode (already enabled in tsconfig)
Destructure request properties: const { github_username } = req.user
One route file per external API service
No business logic in index.ts — only server setup and route mounting
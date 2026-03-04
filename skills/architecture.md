
---

### `skills/01-architecture.md`

```markdown
# Architecture Overview

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter 3.11+ / Dart | Cross-platform mobile app |
| **Backend** | Node.js / Express / TypeScript | API aggregator proxy |
| **Auth** | Supabase Auth | Email/password authentication |
| **Database** | Supabase (PostgreSQL) | User profiles, API keys |
| **External APIs** | GitHub GraphQL, LeetCode GraphQL, WakaTime REST | Developer stats |

## System Diagram



## Data Flow

1. User opens app → `AuthGate` checks Supabase session
2. If no session → `LoginScreen` → user signs in → Supabase returns JWT
3. `AuthGate` detects session → renders `MainScreen` → triggers `DataProvider.loadAllData()`
4. `DataProvider` calls `ApiDataRepository` methods → HTTP GET with Bearer JWT
5. Backend `auth.ts` middleware verifies JWT → fetches `profiles` row → attaches to request
6. Routes use profile data (github_username, etc.) to call external APIs
7. `SimpleCache` prevents hammering external APIs (15 min TTL)
8. Responses parsed into Dart models → `DataProvider` notifies listeners → UI rebuilds

## Key File Paths

| Category | Path | Description |
|----------|------|-------------|
| Entry point | [main.dart](http://_vscodecontentref_/1) | App bootstrap, Supabase init, Provider setup |
| Models | [models.dart](http://_vscodecontentref_/2) | 25 data classes with `fromJson` factories |
| Repository interface | [repository.dart](http://_vscodecontentref_/3) | Abstract `DataRepository` + `MockDataRepository` |
| API repository | [api_repository.dart](http://_vscodecontentref_/4) | HTTP client calling backend |
| State manager | [data_provider.dart](http://_vscodecontentref_/5) | `ChangeNotifier` with all app state |
| Mock data | [mock_data.dart](http://_vscodecontentref_/6) | Hardcoded fallback data |
| Theme | [app_theme.dart](http://_vscodecontentref_/7) | `DevPulseColors`, `DevPulseTheme`, Material theme |
| Theme state | [theme_provider.dart](http://_vscodecontentref_/8) | Dark/light toggle |
| Auth gate | [auth_gate.dart](http://_vscodecontentref_/9) | Supabase session stream router |
| Backend entry | [index.ts](http://_vscodecontentref_/10) | Express server setup |
| Auth middleware | [auth.ts](http://_vscodecontentref_/11) | JWT verify + profile lookup |
| Cache | [cache.ts](http://_vscodecontentref_/12) | In-memory TTL cache |
| DB schema | [supabase_schema.sql](http://_vscodecontentref_/13) | Profiles table + RLS + trigger |
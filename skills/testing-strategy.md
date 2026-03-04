
---

### `skills/04-testing-strategy.md`

```markdown
# Testing Strategy

## Current State: 0% Effective Coverage

- 1 smoke test exists (`test/widget_test.dart`) — **broken** (missing Provider/Supabase setup)
- 0 backend tests
- No test dependencies installed (no mocktail, no vitest)

## Target Directory Structure


test/
helpers/
test_helpers.dart # pumpApp() wrapper, common setup
mock_repository.dart # Mocktail MockDataRepository
unit/
models/
user_data_test.dart
github_stats_test.dart
leetcode_stats_test.dart
wakatime_stats_test.dart
goal_test.dart
weekly_report_test.dart
data_provider/
data_provider_test.dart
api_repository/
api_repository_test.dart
theme/
theme_provider_test.dart
widgets/
glass_card_test.dart
progress_ring_test.dart
contribution_grid_test.dart
pomodoro_timer_test.dart
screens/
auth_gate_test.dart
login_screen_test.dart
dashboard_screen_test.dart
github_screen_test.dart
leetcode_screen_test.dart
goals_screen_test.dart
profile_screen_test.dart
integration/
data_flow_test.dart
auth_flow_test.dart

backend/
tests/
helpers/
setup.ts # Express app factory (no .listen())
fixtures.ts # Mock API responses
unit/
cache.test.ts
middleware/
auth.test.ts
routes/
github.test.ts
leetcode.test.ts
wakatime.test.ts
dashboard.test.ts


## Dependencies to Add

### Flutter (`pubspec.yaml` → `dev_dependencies`)
```yaml
mocktail: ^1.0.0              # Mock generation without codegen
network_image_mock: ^2.0.0    # Mock network images in widget tests

"vitest": "^3.0.0",
"supertest": "^7.0.0",
"@types/supertest": "^6.0.0"


"test": "vitest run",
"test:watch": "vitest"

Test Helpers

test/helpers/test_helpers.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:devpulse/theme/theme_provider.dart';
import 'package:devpulse/data/data_provider.dart';
import 'package:devpulse/data/repository.dart';
import 'package:devpulse/theme/app_theme.dart';

/// Wraps a widget in all required providers for testing.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  DataRepository? repository,
}) async {
  final repo = repository ?? MockDataRepository();
  final dataProvider = DataProvider(repository: repo);
  await dataProvider.loadAllData();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: dataProvider),
      ],
      child: MaterialApp(home: child),
    ),
  );
  await tester.pumpAndSettle();
}

test/helpers/mock_repository.dart

import 'package:mocktail/mocktail.dart';
import 'package:devpulse/data/repository.dart';

class MockRepo extends Mock implements DataRepository {}

What to Test — Priority Order

P0: Model fromJson (Fast wins, catch regressions)

Test	                            What to Verify
Valid JSON → model	            All fields populated correctly
Null/missing fields →defaults   No crash on malformed API response
Empty arrays	                List fields return [] not null
Type mismatches	                int field receiving String from API

P1: DataProvider (Core business logic)


Test	What to Verify
loadAllData() success	All fields non-null, isLoading false, no error
loadAllData() partial failure	Failed service → mock fallback, others succeed
loadAllData() total failure	errorMessage populated, mock fallbacks used
toggleGoal(id)	Flips completed, notifies listeners
addGoal(title, cat)	Inserts at index 0, notifies listeners
deleteGoal(id)	Removes goal, notifies listeners

P2: ApiDataRepository (HTTP layer)
Test	What to Verify
200 response → parsed model	Correct deserialization
401 response → throws	Not silently swallowed
500 response → throws	Error message includes status code
Network error → throws	Timeout, DNS failure
Token included in headers	Bearer JWT present

P3: Widget Tests
Widget	            What to Verify
GlassCard	        Renders child, applies animation
ProgressRing	    Renders at 0/50/100%, shows label
ContributionGrid	Renders 90-day grid, color mapping
PomodoroTimer	    Focus/break modes, start/pause

P4: Screen Tests
Screen	        What to Verify
AuthGate	    No session → LoginScreen, session → MainScreen
LoginScreen	    Empty email validation, submit calls auth
DashboardScreen	Loading state, data state, stat values from provider
GitHubScreen	todayCommits displayed (NOT hardcoded "7")
GoalsScreen	    Goal list renders, add goal sheet opens
ProfileScreen	Stats grid shows real data, sign out button present

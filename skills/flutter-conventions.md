# Flutter Conventions

## State Management

- **Provider + ChangeNotifier** — the only state management pattern in use
- `DataProvider` holds ALL app data (user, GitHub, LeetCode, WakaTime, goals, badges, etc.)
- `ThemeProvider` holds dark/light mode toggle
- Access in widgets: `context.watch<DataProvider>()` for reactive, `context.read<DataProvider>()` for one-shot

```dart
// ✅ Correct — reactive rebuild
final stats = context.watch<DataProvider>().githubStats;

// ✅ Correct — one-shot action
context.read<DataProvider>().toggleGoal(id);

// ❌ Wrong — don't use Provider.of directly
final data = Provider.of<DataProvider>(context);

Theming
ALWAYS use AppTheme.of(context) to get DevPulseTheme
NEVER use Theme.of(context).colorScheme directly — our design tokens live in DevPulseTheme
Colors come from DevPulseColors — static constants


Fonts
Font	Usage	Import
Sora	Body text, labels, buttons	GoogleFonts.sora()
JetBrains Mono	Code, stats numbers, monospace	GoogleFonts.jetBrainsMono()
Instrument Serif	Display headings, hero text	GoogleFonts.instrumentSerif()


lib/
  main.dart                    # Entry point only
  data/
    models.dart                # All data classes
    repository.dart            # Abstract interface + mock impl
    api_repository.dart        # Real HTTP implementation
    data_provider.dart         # ChangeNotifier state manager
    mock_data.dart             # Hardcoded fallback data
  screens/
    auth_gate.dart             # Auth routing (< 100 lines)
    login_screen.dart          # Login form
    main_screen.dart           # Tab navigation shell
    dashboard_screen.dart      # Home/overview
    github_screen.dart         # GitHub stats
    leetcode_screen.dart       # LeetCode stats
    wakatime_screen.dart       # WakaTime stats
    goals_screen.dart          # Goal tracker
    profile_screen.dart        # User profile
  widgets/
    glass_card.dart            # Reusable frosted glass card
    progress_ring.dart         # Circular progress indicator
    contribution_grid.dart     # GitHub-style heatmap
    pomodoro_timer.dart        # Pomodoro timer dialog
    github/                    # (after refactor) GitHub-specific widgets
    dashboard/                 # (after refactor) Dashboard-specific widgets
    profile/                   # (after refactor) Profile-specific widgets
    ...
  theme/
    app_theme.dart             # Design tokens + Material theme
    theme_provider.dart        # Dark/light toggle
  utils/                       # (to create) Shared utilities
    logger.dart                # Structured logging
    language_colors.dart       # GitHub language → color map

Naming Rules
Entity	        Convention	               Example
Files	     snake_case.dart	      github_screen.dart
Classes	    PascalCase matching file	GitHubScreen
Widgets	    PascalCase, noun	  StreakCard,StatTilesRow
Private     methods	_camelCase	    _buildHeader()
Constants	camelCase static	  DevPulseColors.neonGreen
Test files	<source>_test.dart	data_provider_test.dart


Naming Rules
Entity	Convention	Example
Files	snake_case.dart	github_screen.dart
Classes	PascalCase matching file	GitHubScreen
Widgets	PascalCase, noun	StreakCard, StatTilesRow
Private methods	_camelCase	_buildHeader()
Constants	camelCase static	DevPulseColors.neonGreen
Test files	<source>_test.dart	data_provider_test.dart


Anti-Patterns to Avoid

// ❌ Never use dynamic types
Widget _buildSection(dynamic theme) { ... }
// ✅ Use proper types
Widget _buildSection(DevPulseTheme theme) { ... }

// ❌ Never use withOpacity()
color.withOpacity(0.5)
// ✅ Use withValues()
color.withValues(alpha: 0.5)

// ❌ Never hardcode data that comes from API
Text('7')  // commits today
Text('47') // streak
// ✅ Bind to model
Text('${stats.todayCommits}')
Text('${user.streak}')

// ❌ Never use Platform.isAndroid without web guard
if (Platform.isAndroid) { ... }
// ✅ Guard for web
if (!kIsWeb && Platform.isAndroid) { ... }

// ❌ Never swallow errors silently
catch (_) { return mockData; }
// ✅ Log and propagate
catch (e) { debugPrint('[DevPulse] Error: $e'); rethrow; }
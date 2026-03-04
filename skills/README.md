# DevPulse — Skills & Development Guide

This folder is the single source of truth for developing, testing, and maintaining DevPulse.
Read these files before writing any code.

| File | Purpose |
|------|---------|
| [01-architecture.md](01-architecture.md) | System architecture, tech stack, data flow |
| [02-flutter-conventions.md](02-flutter-conventions.md) | Dart/Flutter coding rules, theming, state management |
| [03-backend-conventions.md](03-backend-conventions.md) | Express/TypeScript patterns, middleware, caching |
| [04-testing-strategy.md](04-testing-strategy.md) | Full test plan: what to test, how, directory structure |
| [05-refactoring-guide.md](05-refactoring-guide.md) | Screen decomposition plan with exact line ranges |
| [06-implementation-checklist.md](06-implementation-checklist.md) | Step-by-step task tracker for the full plan |
| [07-known-issues.md](07-known-issues.md) | All discovered bugs and anti-patterns |

## Quick Commands

```bash
# Run Flutter app
flutter run

# Run backend
cd backend && npm run dev

# Run Flutter tests
flutter test

# Run backend tests (after setup)
cd backend && npm test

# Analyze Dart code
flutter analyze
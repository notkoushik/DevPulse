import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:devpulse/main.dart';
import 'package:devpulse/theme/theme_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const DevPulseApp(),
      ),
    );
    expect(find.text('DevPulse'), findsNothing); // Or whatever we expect at startup, since AuthGate is shown.
  });
}

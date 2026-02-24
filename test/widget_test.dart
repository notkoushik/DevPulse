import 'package:flutter_test/flutter_test.dart';

import 'package:devpulse/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DevPulseApp());
    expect(find.text('DevPulse'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ur_war/main.dart';

void main() {
  testWidgets('UR WAR main menu smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const UrWarApp());

    // Verify that the title and play button are shown.
    expect(find.text('UR WAR'), findsOneWidget);
    expect(find.text('JUGAR'), findsOneWidget);
    expect(find.text('AJUSTES'), findsOneWidget);
    expect(find.text('CRÉDITOS & OPEN SOURCE'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_flutter/main.dart';

void main() {
  testWidgets('renders the Hermes public landing page', (tester) async {
    await tester.pumpWidget(const HermesBootstrap());
    await tester.pumpAndSettle();

    expect(find.text('Hermes'), findsWidgets);
    expect(find.textContaining('Verified leads'), findsOneWidget);
  });
}

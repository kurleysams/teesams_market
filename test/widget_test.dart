import 'package:flutter_test/flutter_test.dart';

import 'package:teesams_market/app.dart';

void main() {
  testWidgets('Teesams Market app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TeesamsMarketApp());
    await tester.pump();

    expect(find.byType(TeesamsMarketApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_ledger/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PocketLedgerApp(isSetup: true));
    expect(find.text('PocketLedger'), findsOneWidget);
  });
}

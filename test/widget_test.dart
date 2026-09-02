import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_ledger/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PocketLedgerApp());
    expect(find.text('PocketLedger'), findsOneWidget);
  });
}

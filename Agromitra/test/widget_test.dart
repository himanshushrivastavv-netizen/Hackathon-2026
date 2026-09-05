import 'package:flutter_test/flutter_test.dart';
import 'package:agromitra/main.dart';
import 'package:agromitra/utils/price_logic.dart';

void main() {
  testWidgets('AgroMitra App launches and displays language screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AgroMitraApp());
    await tester.pumpAndSettle();

    // Verify app brand and language selection
    expect(find.text('AgroMitra'), findsOneWidget);
    expect(find.text('Choose Your Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('मराठी'), findsOneWidget);
  });

  test('PriceLogic calculates transparent quality multipliers accurately', () {
    const double modal = 24.0;
    // Grade A: 24 * 1.10 = 26.40
    expect(PriceLogic.calculateSuggestedPrice(modal, 'Grade A'), 26.40);
    // Grade B: 24 * 1.00 = 24.00
    expect(PriceLogic.calculateSuggestedPrice(modal, 'Grade B'), 24.00);
    // Grade C: 24 * 0.90 = 21.60
    expect(PriceLogic.calculateSuggestedPrice(modal, 'Grade C'), 21.60);
  });
}

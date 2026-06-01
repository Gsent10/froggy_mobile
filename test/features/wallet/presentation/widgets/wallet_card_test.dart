import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';
import 'package:froggy_mobile/features/wallet/presentation/widgets/wallet_card.dart';

void main() {
  testWidgets('WalletCard renders the correct currency symbol and balance', (
    WidgetTester tester,
  ) async {
    // Create a mock wallet
    final wallet = Wallet(
      id: 1,
      currencyCode: 'GBP',
      currencySymbol: '£',
      balance: 1250.50,
      cardNumber: '1234567812345678',
    );

    final theme = themeFor('GBP');

    // Build the WalletCard widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WalletCard(
            cardWidth: 350,
            cardHeight: 200,
            wallet: wallet,
            theme: theme,
          ),
        ),
      ),
    );

    // Verify currency symbol and formatted balance are rendered
    // The amount should be formatted as 1,250.50
    expect(find.text('£1,250.50'), findsOneWidget);

    // Verify currency code is rendered
    expect(find.text('GBP'), findsOneWidget);

    // Verify country name is rendered
    expect(find.text('United Kingdom'), findsOneWidget);
  });

  testWidgets('WalletCard renders NGN symbol when wallet is null', (
    WidgetTester tester,
  ) async {
    final theme = themeFor('NGN');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WalletCard(
            cardWidth: 350,
            cardHeight: 200,
            wallet: null,
            theme: theme,
          ),
        ),
      ),
    );

    // Default symbol is ₦ and default balance is 0.00
    expect(find.text('₦0.00'), findsOneWidget);
    expect(find.text('NGN'), findsOneWidget);
  });
}

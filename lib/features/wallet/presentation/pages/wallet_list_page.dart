import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';

class WalletListPage extends StatelessWidget {
  const WalletListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kBlackColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Wallets',
          style: SafeGoogleFont(
            'DM Sans',
            fontSize: sw * kFontS,
            fontWeight: FontWeight.w700,
            color: kBlackColor,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final wallets = state.data?.wallets ?? [];

          if (wallets.isEmpty) {
            return const Center(child: Text('No wallets found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(FetchDashboardData());
            },
            child: ListView.builder(
              padding: EdgeInsets.all(sw * kHorizontalPadding),
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                return _WalletListItem(wallet: wallet);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-wallet');
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: kWhiteColor),
      ),
    );
  }
}

class _WalletListItem extends StatelessWidget {
  final Wallet wallet;

  const _WalletListItem({required this.wallet});

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/wallet-details', arguments: wallet.id);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: sw * kVerticalPadding),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: kBgColor,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                getFlagPath(wallet.currencyCode),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_balance_wallet,
                  color: kPrimaryColor,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${wallet.currencyCode} Wallet',
                    style: SafeGoogleFont(
                      'DM Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    wallet.cardNumber ?? '**** **** **** ****',
                    style: SafeGoogleFont(
                      'DM Sans',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${wallet.currencySymbol}${wallet.balance.toStringAsFixed(2)}',
              style: SafeGoogleFont(
                'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

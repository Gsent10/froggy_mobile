import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/core/widgets/loading.dart';
import 'package:froggy_mobile/features/wallet/bloc/wallet_bloc.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';

class WalletDetailsPage extends StatefulWidget {
  final int walletId;

  const WalletDetailsPage({super.key, required this.walletId});

  @override
  State<WalletDetailsPage> createState() => _WalletDetailsPageState();
}

class _WalletDetailsPageState extends State<WalletDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(FetchWalletDetails(widget.walletId));
  }

  String _formatAmount(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[0]},',
    );
    return '$intPart.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final sh = context.screenHeight;

    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: kBgColor,
              appBar: AppBar(
                backgroundColor: kBgColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: kBlackColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Wallet Details',
                  style: SafeGoogleFont(
                    'DM Sans',
                    fontSize: sw * kFontS,
                    fontWeight: FontWeight.w700,
                    color: kBlackColor,
                  ),
                ),
                centerTitle: true,
              ),
              body: state.status == WalletStatus.error
                  ? Center(
                      child: Text(state.errorMessage ?? 'An error occurred'),
                    )
                  : state.wallet == null && state.status != WalletStatus.loading
                  ? const Center(child: Text('Wallet not found'))
                  : state.wallet == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<WalletBloc>().add(
                          FetchWalletDetails(widget.walletId),
                        );
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * kHorizontalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: sh * 0.02),
                              _LargeWalletCard(
                                wallet: state.wallet!,
                                formatAmount: _formatAmount,
                              ),
                              SizedBox(height: sh * 0.04),
                              Text(
                                'Recent Activity',
                                style: SafeGoogleFont(
                                  'DM Sans',
                                  fontSize: sw * kFontS,
                                  fontWeight: FontWeight.w700,
                                  color: kBlackColor,
                                ),
                              ),
                              SizedBox(height: sh * 0.02),
                              if (state.activities.isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: context.screenHeight * kSpacingL,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: context.screenWidth * 0.18,
                                          height: context.screenWidth * 0.18,
                                          decoration: const BoxDecoration(
                                            color: Color(0xffF2F4F8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.receipt_long_outlined,
                                            size: context.screenWidth * 0.08,
                                            color: kSecondaryColor,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              context.screenHeight * kSpacingM,
                                        ),
                                        Text(
                                          'No activity yet',
                                          style: SafeGoogleFont(
                                            'DM Sans',
                                            fontSize:
                                                context.screenWidth * kFontS,
                                            fontWeight: FontWeight.w600,
                                            color: kBlackColor,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              context.screenHeight * kSpacingS,
                                        ),
                                        Text(
                                          'Make a transfer or add money\nto get started',
                                          textAlign: TextAlign.center,
                                          style: SafeGoogleFont(
                                            'DM Sans',
                                            fontSize:
                                                context.screenWidth *
                                                (kFontXS - 0.005),
                                            color: kSecondaryColor,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: state.activities.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: sh * kSpacingM,
                                    thickness: 1,
                                    color: const Color(0xffF2F4F8),
                                  ),
                                  itemBuilder: (context, index) {
                                    return _ActivityTile(
                                      activity: state.activities[index],
                                      wallet: state.wallet!,
                                      formatAmount: _formatAmount,
                                    );
                                  },
                                ),
                              SizedBox(height: sh * 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            if (state.status == WalletStatus.loading) const Loading(),
          ],
        );
      },
    );
  }
}

class _LargeWalletCard extends StatelessWidget {
  final Wallet wallet;
  final String Function(double) formatAmount;

  const _LargeWalletCard({required this.wallet, required this.formatAmount});

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final sh = context.screenHeight;

    return Container(
      width: double.infinity,
      height: sh * 0.25,
      padding: EdgeInsets.all(sw * 0.07),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(sw * 0.06),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff1443C3), Color(0xff0A235C)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1443C3).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  color: Colors.white70,
                ),
              ),
              const Icon(Icons.info_outline, color: Colors.white70),
            ],
          ),
          Text(
            '${wallet.currencySymbol}${formatAmount(wallet.balance)}',
            style: SafeGoogleFont(
              'DM Sans',
              fontSize: sw * 0.09,
              fontWeight: FontWeight.w700,
              color: kWhiteColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                wallet.cardNumber ?? '**** **** **** 1234',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  color: Colors.white70,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                wallet.currencyCode,
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  fontWeight: FontWeight.w700,
                  color: kWhiteColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Activity activity;
  final Wallet wallet;
  final String Function(double) formatAmount;

  const _ActivityTile({
    required this.activity,
    required this.wallet,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final isCredit = activity.isCredit;

    return Row(
      children: [
        Container(
          width: sw * 0.11,
          height: sw * 0.11,
          decoration: BoxDecoration(
            color: const Color(0xffF2F4F8),
            borderRadius: BorderRadius.circular(sw * 0.03),
          ),
          child: Icon(
            isCredit
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            size: sw * 0.055,
            color: isCredit ? const Color(0xff1E7C47) : kSecondaryColor,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  fontWeight: FontWeight.w600,
                  color: kBlackColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                activity.date,
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * (kFontXS - 0.005),
                  color: kSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${isCredit ? '+' : '-'}${wallet.currencySymbol}${formatAmount(activity.amount)}',
          style: SafeGoogleFont(
            'DM Sans',
            fontSize: sw * kFontXS,
            fontWeight: FontWeight.w700,
            color: isCredit ? const Color(0xff1E7C47) : kBlackColor,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Wallet card theming by currency code
// ─────────────────────────────────────────────────────────────────────────────
class _WalletTheme {
  final Color cardColor;
  final Color accentColor;
  final String flagAsset;
  final String countryName;

  const _WalletTheme({
    required this.cardColor,
    required this.accentColor,
    required this.flagAsset,
    required this.countryName,
  });
}

const _walletThemes = <String, _WalletTheme>{
  'GBP': _WalletTheme(
    cardColor: Color(0xff003078),
    accentColor: Color(0xffCF142B),
    flagAsset: 'assets/flags/GB.png',
    countryName: 'United Kingdom',
  ),
  'NGN': _WalletTheme(
    cardColor: Color(0xff1E7C47),
    accentColor: Color(0xffA8E6C3),
    flagAsset: 'assets/flags/NG.png',
    countryName: 'Nigeria',
  ),
  'USD': _WalletTheme(
    cardColor: Color(0xff1A3A5C),
    accentColor: Color(0xffB22234),
    flagAsset: 'assets/flags/US.png',
    countryName: 'United States',
  ),
  'GHS': _WalletTheme(
    cardColor: Color(0xff8B0000),
    accentColor: Color(0xffFCD116),
    flagAsset: 'assets/flags/GH.png',
    countryName: 'Ghana',
  ),
  'KES': _WalletTheme(
    cardColor: Color(0xff1a1a1a),
    accentColor: Color(0xffBB0000),
    flagAsset: 'assets/flags/KE.png',
    countryName: 'Kenya',
  ),
};

_WalletTheme _themeFor(String currencyCode) =>
    _walletThemes[currencyCode.toUpperCase()] ??
    const _WalletTheme(
      cardColor: Color(0xff1a1a1a),
      accentColor: Color(0xff444444),
      flagAsset: 'assets/flags/NG.png',
      countryName: 'Unknown',
    );

// ─────────────────────────────────────────────────────────────────────────────
// Home Page
// ─────────────────────────────────────────────────────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DashboardStatus.error) {
            return Center(
              child: Text(state.errorMessage ?? 'An error occurred'),
            );
          }

          if (state.data == null) {
            return const Center(child: Text('No data available'));
          }

          final data = state.data!;
          final primaryWallet = data.wallets.isNotEmpty
              ? data.wallets.first
              : null;
          final recentActivities = data.activities.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(FetchDashboardData());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenWidth * kHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.screenHeight * kSpacingXL),

                    // ── Top bar ──────────────────────────────────────────
                    _TopBar(userInfo: data.userInfo),

                    SizedBox(height: context.screenHeight * kSpacingM),

                    // ── Balance card(s) ──────────────────────────────────
                    _BalanceCard(wallets: data.wallets),

                    SizedBox(height: context.screenHeight * kSpacingL),

                    // ── Quick actions ────────────────────────────────────
                    const _QuickActions(),

                    SizedBox(height: context.screenHeight * kSpacingL),

                    // ── Recent transactions header (hidden when empty) ───
                    if (recentActivities.isNotEmpty)
                      _SectionHeader(
                        title: 'Recent transactions',
                        actionLabel: 'View all',
                        onTap: () {
                          // TODO: navigate to full transactions screen
                        },
                      ),

                    SizedBox(height: context.screenHeight * kSpacingS),

                    // ── Transactions list or empty state ─────────────────
                    if (recentActivities.isEmpty)
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
                                height: context.screenHeight * kSpacingM,
                              ),
                              Text(
                                'No transactions yet',
                                style: SafeGoogleFont(
                                  'DM Sans',
                                  fontSize: context.screenWidth * kFontS,
                                  fontWeight: FontWeight.w600,
                                  color: kBlackColor,
                                ),
                              ),
                              SizedBox(
                                height: context.screenHeight * kSpacingS,
                              ),
                              Text(
                                'Make a transfer or add money\nto get started',
                                textAlign: TextAlign.center,
                                style: SafeGoogleFont(
                                  'DM Sans',
                                  fontSize:
                                      context.screenWidth * (kFontXS - 0.005),
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
                        itemCount: recentActivities.length,
                        separatorBuilder: (_, __) => Divider(
                          height: context.screenHeight * kSpacingM,
                          thickness: 1,
                          color: const Color(0xffF2F4F8),
                        ),
                        itemBuilder: (context, index) {
                          return _ActivityTile(
                            activity: recentActivities[index],
                            wallet: primaryWallet,
                          );
                        },
                      ),

                    SizedBox(height: context.screenHeight * kSpacingM),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.userInfo});

  final UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;

    return Row(
      children: [
        CircleAvatar(
          radius: sw * 0.045,
          backgroundColor: const Color(0xffE8EDF8),
          backgroundImage: userInfo.profileImage != null
              ? NetworkImage(userInfo.profileImage!)
              : null,
          child: userInfo.profileImage == null
              ? Icon(
                  Icons.person_outline_rounded,
                  size: sw * 0.05,
                  color: kPrimaryColor,
                )
              : null,
        ),
        SizedBox(width: sw * 0.03),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: SafeGoogleFont(
                'DM Sans',
                fontSize: sw * (kFontXS - 0.005),
                color: kSecondaryColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              userInfo.fullName.split(' ').first,
              style: SafeGoogleFont(
                'DM Sans',
                fontSize: sw * kFontS,
                fontWeight: FontWeight.w700,
                color: kBlackColor,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            // TODO: navigate to recent activity screen
          },
          child: Icon(
            Icons.history_rounded,
            size: sw * 0.06,
            color: kBlackColor,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Balance Card — horizontally scrollable, one card per wallet
// ─────────────────────────────────────────────────────────────────────────────
class _BalanceCard extends StatefulWidget {
  const _BalanceCard({required this.wallets});

  final List<Wallet> wallets;

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  late final List<ValueNotifier<bool>> _visibilityNotifiers;

  @override
  void initState() {
    super.initState();
    _visibilityNotifiers = List.generate(
      widget.wallets.isEmpty ? 1 : widget.wallets.length,
      (_) => ValueNotifier(false),
    );
  }

  @override
  void dispose() {
    for (final n in _visibilityNotifiers) {
      n.dispose();
    }
    super.dispose();
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
    final cardHeight = sh * 0.20;

    if (widget.wallets.isEmpty) {
      return SizedBox(
        height: cardHeight,
        child: _SingleWalletCard(
          cardWidth: sw,
          cardHeight: cardHeight,
          wallet: null,
          theme: _themeFor('NGN'),
          visibilityNotifier: _visibilityNotifiers.first,
          formatAmount: _formatAmount,
        ),
      );
    }

    // One wallet — full width, fixed height, no scroll chrome
    if (widget.wallets.length == 1) {
      return SizedBox(
        height: cardHeight,
        child: _SingleWalletCard(
          cardWidth: sw,
          cardHeight: cardHeight,
          wallet: widget.wallets.first,
          theme: _themeFor(widget.wallets.first.currencyCode),
          visibilityNotifier: _visibilityNotifiers.first,
          formatAmount: _formatAmount,
        ),
      );
    }

    return SizedBox(
      height: cardHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // Negative margin trick: allow cards to bleed past the
        // parent padding so the peek is visible, without Clip.none.
        child: Row(
          children: [
            for (int i = 0; i < widget.wallets.length; i++) ...[
              _SingleWalletCard(
                cardWidth: sw * 0.88,
                cardHeight: cardHeight,
                wallet: widget.wallets[i],
                theme: _themeFor(widget.wallets[i].currencyCode),
                visibilityNotifier: _visibilityNotifiers[i],
                formatAmount: _formatAmount,
              ),
              if (i < widget.wallets.length - 1) SizedBox(width: sw * 0.03),
            ],
          ],
        ),
      ),
    );
  }
}

class _SingleWalletCard extends StatelessWidget {
  const _SingleWalletCard({
    required this.cardWidth,
    required this.cardHeight,
    required this.wallet,
    required this.theme,
    required this.visibilityNotifier,
    required this.formatAmount,
  });

  final double cardWidth;
  final double cardHeight;
  final Wallet? wallet;
  final _WalletTheme theme;
  final ValueNotifier<bool> visibilityNotifier;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final sw = cardWidth;
    final sh = cardHeight;

    final symbol = wallet?.currencySymbol ?? '₦';
    final balance = wallet?.balance ?? 0.0;

    return ValueListenableBuilder<bool>(
      valueListenable: visibilityNotifier,
      builder: (context, visible, _) {
        return Container(
          width: sw,
          height: sh,
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.055,
            vertical: sw * 0.045,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(sw * 0.045),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.cardColor,
                Color.lerp(theme.cardColor, Colors.black, 0.3)!,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisSize must NOT be min — we want the column to fill
            // the fixed height so spacing is distributed correctly.
            mainAxisSize: MainAxisSize.max,
            children: [
              // ── Flag + country name | eye toggle ────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(sw * 0.01),
                        child: Image.asset(
                          theme.flagAsset,
                          width: sw * 0.07,
                          height: sw * 0.045,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: sw * 0.07,
                            height: sw * 0.045,
                            decoration: BoxDecoration(
                              color: theme.accentColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(sw * 0.01),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: sw * 0.025),
                      Text(
                        theme.countryName,
                        style: SafeGoogleFont(
                          'DM Sans',
                          fontSize: sw * (kFontXS - 0.005),
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () =>
                        visibilityNotifier.value = !visibilityNotifier.value,
                    child: Icon(
                      visible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white60,
                      size: sw * 0.065,
                    ),
                  ),
                ],
              ),

              // Fixed gap instead of Spacer — no unbounded height risk
              SizedBox(height: sh * 0.12),

              // ── Balance ──────────────────────────────────────────────
              Text(
                visible ? '$symbol${formatAmount(balance)}' : '$symbol ••••••',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontL,
                  fontWeight: FontWeight.w700,
                  color: kWhiteColor,
                ),
              ),

              Text(
                'Account balance',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  color: Colors.white60,
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(height: sh * 0.07),

              GestureDetector(
                onTap: () {
                  // TODO: navigate to account details
                },
                child: Text(
                  'Account details',
                  style: SafeGoogleFont(
                    'DM Sans',
                    fontSize: sw * kFontXS,
                    color: kWhiteColor,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: kWhiteColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final sh = context.screenHeight;

    const actions = [
      (Icons.send_rounded, 'Transfer'),
      (Icons.add_circle_outline_rounded, 'Add money'),
      (Icons.credit_card_rounded, 'Cards'),
      (Icons.receipt_long_rounded, 'Bills'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        return GestureDetector(
          onTap: () {
            // TODO: route based on a.$2
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: sw * 0.13,
                height: sw * 0.13,
                decoration: BoxDecoration(
                  color: const Color(0xffF2F4F8),
                  borderRadius: BorderRadius.circular(sw * 0.035),
                ),
                child: Icon(a.$1, size: sw * 0.06, color: kBlackColor),
              ),
              SizedBox(height: sh * kSpacingS),
              Text(
                a.$2,
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * (kFontXS - 0.005),
                  fontWeight: FontWeight.w500,
                  color: kBlackColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: SafeGoogleFont(
            'DM Sans',
            fontSize: sw * kFontS,
            fontWeight: FontWeight.w600,
            color: kBlackColor,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: SafeGoogleFont(
              'DM Sans',
              fontSize: sw * kFontXS,
              fontWeight: FontWeight.w500,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity, required this.wallet});

  final Activity activity;
  final Wallet? wallet;

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

    final symbol = wallet?.currencySymbol ?? '₦';
    final isCredit = activity.isCredit;

    return Row(
      children: [
        // Icon container
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

        // Title + subtitle
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
              SizedBox(height: sh * 0.003),
              Text(
                activity.subtitle.isNotEmpty
                    ? activity.subtitle
                    : activity.date,
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * (kFontXS - 0.005),
                  color: kSecondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Amount + status badge
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : '-'}$symbol${_formatAmount(activity.amount)}',
              style: SafeGoogleFont(
                'DM Sans',
                fontSize: sw * kFontXS,
                fontWeight: FontWeight.w700,
                color: isCredit ? const Color(0xff1E7C47) : kBlackColor,
              ),
            ),
            SizedBox(height: sh * 0.003),
            Container(
              width: sw * 0.04,
              height: sw * 0.04,
              decoration: const BoxDecoration(
                color: Color(0xff1E7C47),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: sw * 0.025,
                color: kWhiteColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

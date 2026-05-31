import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';

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

          // Use the first wallet as the primary balance, fall back gracefully
          final primaryWallet = data.wallets.isNotEmpty
              ? data.wallets.first
              : null;

          // Show only the 5 most-recent activities on the home page
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

                    _TopBar(userInfo: data.userInfo),

                    SizedBox(height: context.screenHeight * kSpacingM),

                    _BalanceCard(wallet: primaryWallet),

                    SizedBox(height: context.screenHeight * kSpacingL),

                    const _QuickActions(),

                    SizedBox(height: context.screenHeight * kSpacingL),

                    if (recentActivities.isNotEmpty)
                      _SectionHeader(
                        title: 'Recent transactions',
                        actionLabel: 'View all',
                        onTap: () {
                          // TODO: navigate to full transactions screen
                        },
                      ),

                    SizedBox(height: context.screenHeight * kSpacingS),

                    if (recentActivities.isEmpty)
                      SizedBox()
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
          child: Icon(
            Icons.person_outline_rounded,
            size: sw * 0.05,
            color: kPrimaryColor,
          ),
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
              // Show first name only to keep the header compact
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
// Balance Card  (StatefulWidget — owns the show/hide toggle locally)
// ─────────────────────────────────────────────────────────────────────────────
class _BalanceCard extends StatefulWidget {
  const _BalanceCard({required this.wallet});

  final Wallet? wallet;

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _visible = false;

  /// Format a double like 50000.0 → "50,000.00"
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

    final symbol = widget.wallet?.currencySymbol ?? '₦';
    final balance = widget.wallet?.balance ?? 0.0;
    final maskedCard = widget.wallet?.cardNumber != null
        ? '•••• ${widget.wallet!.cardNumber!.substring(widget.wallet!.cardNumber!.length - 4)}'
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.05),
      decoration: BoxDecoration(
        color: kBlackColor,
        borderRadius: BorderRadius.circular(sw * 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _visible
                    ? '$symbol${_formatAmount(balance)}'
                    : '$symbol ••••••',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontL,
                  fontWeight: FontWeight.w700,
                  color: kWhiteColor,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _visible = !_visible),
                child: Icon(
                  _visible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white60,
                  size: sw * 0.055,
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.005),
          Text(
            'Account balance',
            style: SafeGoogleFont(
              'DM Sans',
              fontSize: sw * kFontXS,
              color: Colors.white60,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (maskedCard != null) ...[
            SizedBox(height: sh * 0.006),
            Text(
              maskedCard,
              style: SafeGoogleFont(
                'DM Sans',
                fontSize: sw * (kFontXS - 0.005),
                color: Colors.white38,
              ),
            ),
          ],
          SizedBox(height: sh * 0.012),
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
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Activity Tile  (maps directly to your Activity model)
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity, required this.wallet});

  final Activity activity;
  final Wallet? wallet;

  /// Format double → "10,500,800.00"
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
            // Green check badge (always shown; remove if you add a status field)
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: context.screenWidth * 0.15,
                    color: kSecondaryColor,
                  ),
                  SizedBox(height: context.screenHeight * kSpacingM),
                  Text(
                    'Request failed',
                    style: SafeGoogleFont(
                      'DM Sans',
                      fontSize: context.screenWidth * kFontS,
                      fontWeight: FontWeight.w600,
                      color: kBlackColor,
                    ),
                  ),
                  SizedBox(height: context.screenHeight * kSpacingS),
                  Text(
                    'Something went wrong.\nPlease try again.',
                    textAlign: TextAlign.center,
                    style: SafeGoogleFont(
                      'DM Sans',
                      fontSize: context.screenWidth * (kFontXS - 0.005),
                      color: kSecondaryColor,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: context.screenHeight * kSpacingL),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<DashboardBloc>().add(FetchDashboardData()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: kWhiteColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.screenWidth * 0.1,
                        vertical: context.screenHeight * 0.016,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          context.screenWidth * 0.03,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Try again',
                      style: SafeGoogleFont(
                        'DM Sans',
                        fontSize: context.screenWidth * kFontXS,
                        fontWeight: FontWeight.w600,
                        color: kWhiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.data == null && state.status != DashboardStatus.loading) {
            return const Center(child: Text('No data available'));
          }

          if (state.data == null) {
            return const SizedBox.shrink();
          }

          final data = state.data!;
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
                    _BalanceCard(wallets: data.wallets),
                    SizedBox(height: context.screenHeight * kSpacingL),
                    const _QuickActions(),
                    SizedBox(height: context.screenHeight * kSpacingL),
                    if (recentActivities.isNotEmpty)
                      _SectionHeader(
                        title: 'Recent transactions',
                        actionLabel: 'View all',
                        onTap: () {
                          Navigator.pushNamed(context, '/transactions');
                        },
                      ),
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
          onTap: () => Navigator.pushNamed(context, '/activity'),
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

class _BalanceCard extends StatefulWidget {
  const _BalanceCard({required this.wallets});

  final List<Wallet> wallets;

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  final Map<int, ValueNotifier<bool>> _visibilityNotifiers = {};
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _activeIndex = ValueNotifier(0);

  ValueNotifier<bool> _notifierFor(int index) =>
      _visibilityNotifiers.putIfAbsent(index, () => ValueNotifier(false));

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final sw = _scrollController.position.viewportDimension;
    final cardWidth = sw * 0.88 + sw * 0.03; // card width + gap
    final index = (_scrollController.offset / cardWidth).round();
    final clamped = index.clamp(0, widget.wallets.length - 1);
    if (_activeIndex.value != clamped) _activeIndex.value = clamped;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _activeIndex.dispose();
    for (final n in _visibilityNotifiers.values) {
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
          visibilityNotifier: _notifierFor(0),
          formatAmount: _formatAmount,
        ),
      );
    }

    if (widget.wallets.length == 1) {
      return SizedBox(
        height: cardHeight,
        child: _SingleWalletCard(
          cardWidth: sw,
          cardHeight: cardHeight,
          wallet: widget.wallets.first,
          theme: _themeFor(widget.wallets.first.currencyCode),
          visibilityNotifier: _notifierFor(0),
          formatAmount: _formatAmount,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: cardHeight,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(),
            child: Row(
              children: [
                for (int i = 0; i < widget.wallets.length; i++) ...[
                  _SingleWalletCard(
                    cardWidth: sw * 0.88,
                    cardHeight: cardHeight,
                    wallet: widget.wallets[i],
                    theme: _themeFor(widget.wallets[i].currencyCode),
                    visibilityNotifier: _notifierFor(i),
                    formatAmount: _formatAmount,
                  ),
                  if (i < widget.wallets.length - 1) SizedBox(width: sw * 0.03),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: sw * 0.03),
        ValueListenableBuilder<int>(
          valueListenable: _activeIndex,
          builder: (context, active, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.wallets.length, (i) {
                final isActive = i == active;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.symmetric(horizontal: sw * 0.008),
                  width: isActive ? sw * 0.05 : sw * 0.02,
                  height: sw * 0.02,
                  decoration: BoxDecoration(
                    color: isActive
                        ? kPrimaryColor
                        : kPrimaryColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(sw * 0.01),
                  ),
                );
              }),
            );
          },
        ),
      ],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
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
              SizedBox(height: sh * 0.12),
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
                'Wallet balance',
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
                  if (wallet != null) {
                    Navigator.pushNamed(
                      context,
                      '/wallet-details',
                      arguments: wallet!.id,
                    );
                  }
                },
                child: Text(
                  'Wallet details',
                  style: SafeGoogleFont(
                    'DM Sans',
                    fontSize: sw * kFontS,
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
      (Icons.credit_card_rounded, 'Wallets'),
      (Icons.receipt_long_rounded, 'Bills'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        return GestureDetector(
          onTap: () {
            switch (a.$2) {
              case 'Wallets':
                Navigator.pushNamed(context, '/wallet-list');
                break;
              case 'Transfer':
                Navigator.pushNamed(context, '/transfer');
                break;
              case 'Add money':
                Navigator.pushNamed(context, '/topup');
                break;
            }
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
  const _ActivityTile({required this.activity});

  final Activity activity;

  String _formatAmount(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[0]},',
    );
    return '$intPart.${parts[1]}';
  }

  String get _currencySymbol {
    const currencySymbols = {
      'GBP': '£',
      'NGN': '₦',
      'USD': '\$',
      'GHS': 'GH₵',
      'KES': 'KSh',
    };
    return currencySymbols[activity.currencyCode] ?? '₦';
  }

  String get _title {
    switch (activity.type) {
      case 'topup':
        return 'Top Up';
      case 'transfer':
        return 'Transfer';
      case 'withdrawal':
        return 'Withdrawal';
      default:
        return activity.type.isNotEmpty
            ? activity.type[0].toUpperCase() + activity.type.substring(1)
            : activity.reference;
    }
  }

  String get _subtitle {
    final method = activity.paymentMethod.replaceAll('_', ' ');
    return method.isNotEmpty
        ? method[0].toUpperCase() + method.substring(1)
        : activity.reference;
  }

  Color get _statusColor {
    switch (activity.status) {
      case 'success':
        return const Color(0xff1E7C47);
      case 'pending':
        return const Color(0xffF59E0B);
      case 'failed':
        return const Color(0xffEF4444);
      default:
        return kSecondaryColor;
    }
  }

  IconData get _statusIcon {
    switch (activity.status) {
      case 'success':
        return Icons.check_rounded;
      case 'pending':
        return Icons.access_time_rounded;
      case 'failed':
        return Icons.close_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String get _formattedDate {
    try {
      final dt = DateTime.parse(activity.createdAt).toLocal();
      return '${dt.day} ${_monthName(dt.month)}, ${_padTwo(dt.hour)}:${_padTwo(dt.minute)}';
    } catch (_) {
      return activity.createdAt;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _padTwo(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final sh = context.screenHeight;
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
                _title,
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
                '$_subtitle · $_formattedDate',
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : '-'}$_currencySymbol${_formatAmount(activity.amount)}',
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
              decoration: BoxDecoration(
                color: _statusColor,
                shape: BoxShape.circle,
              ),
              child: Icon(_statusIcon, size: sw * 0.025, color: kWhiteColor),
            ),
          ],
        ),
      ],
    );
  }
}

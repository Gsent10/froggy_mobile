import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';
import 'package:froggy_mobile/features/history/bloc/history_bloc.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(FetchTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final sh = context.screenHeight;

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: sw * 0.05,
            color: kBlackColor,
          ),
        ),
        title: Text(
          'Transactions',
          style: SafeGoogleFont(
            'DM Sans',
            fontSize: sw * kFontS,
            fontWeight: FontWeight.w600,
            color: kBlackColor,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        buildWhen: (prev, curr) =>
            prev.transactionsStatus != curr.transactionsStatus ||
            prev.transactions != curr.transactions,
        builder: (context, state) {
          return switch (state.transactionsStatus) {
            HistoryStatus.initial || HistoryStatus.loading => _LoadingView(
              sw: sw,
              sh: sh,
              label: 'Loading transactions…',
            ),
            HistoryStatus.error => _ErrorView(
              sw: sw,
              sh: sh,
              onRetry: () {
                context.read<HistoryBloc>().add(FetchTransactions());
              },
            ),
            HistoryStatus.loaded =>
              state.transactions.isEmpty
                  ? _EmptyView(
                      sw: sw,
                      sh: sh,
                      icon: Icons.receipt_long_outlined,
                      title: 'No transactions yet',
                      subtitle: 'Make a transfer or add money\nto get started',
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<HistoryBloc>().add(FetchTransactions());
                      },
                      color: kPrimaryColor,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * kHorizontalPadding,
                          vertical: sh * kSpacingM,
                        ),
                        itemCount: state.transactions.length,
                        separatorBuilder: (_, __) => Divider(
                          height: sh * kSpacingM,
                          thickness: 1,
                          color: const Color(0xffF2F4F8),
                        ),
                        itemBuilder: (context, index) =>
                            _ActivityTile(activity: state.transactions[index]),
                      ),
                    ),
          };
        },
      ),
    );
  }
}

// ─── Tile ────────────────────────────────────────────────────────────────────

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final Activity activity;

  static const _currencySymbols = {
    'GBP': '£',
    'NGN': '₦',
    'USD': '\$',
    'GHS': 'GH₵',
    'KES': 'KSh',
  };

  String _formatAmount(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[0]},',
    );
    return '$intPart.${parts[1]}';
  }

  String get _currencySymbol => _currencySymbols[activity.currencyCode] ?? '₦';

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

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.sw, required this.sh, required this.label});

  final double sw;
  final double sh;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 2.5),
          SizedBox(height: sh * kSpacingM),
          Text(
            label,
            style: SafeGoogleFont(
              'DM Sans',
              fontSize: sw * kFontXS,
              color: kSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.sw, required this.sh, required this.onRetry});

  final double sw;
  final double sh;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * kHorizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: sw * 0.15,
              color: kSecondaryColor,
            ),
            SizedBox(height: sh * kSpacingM),
            Text(
              'Request failed',
              style: SafeGoogleFont(
                'DM Sans',
                fontSize: sw * kFontS,
                fontWeight: FontWeight.w600,
                color: kBlackColor,
              ),
            ),
            SizedBox(height: sh * kSpacingS),
            Text(
              'Something went wrong.\nPlease try again.',
              textAlign: TextAlign.center,
              style: SafeGoogleFont(
                'DM Sans',
                fontSize: sw * (kFontXS - 0.005),
                color: kSecondaryColor,
                height: 1.5,
              ),
            ),
            SizedBox(height: sh * kSpacingL),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kWhiteColor,
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.1,
                  vertical: sh * 0.016,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sw * 0.03),
                ),
                elevation: 0,
              ),
              child: Text(
                'Try again',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  fontWeight: FontWeight.w600,
                  color: kWhiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.sw,
    required this.sh,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final double sw;
  final double sh;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: sw * 0.18,
            height: sw * 0.18,
            decoration: const BoxDecoration(
              color: Color(0xffF2F4F8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: sw * 0.08, color: kSecondaryColor),
          ),
          SizedBox(height: sh * kSpacingM),
          Text(
            title,
            style: SafeGoogleFont(
              'DM Sans',
              fontSize: sw * kFontS,
              fontWeight: FontWeight.w600,
              color: kBlackColor,
            ),
          ),
          SizedBox(height: sh * kSpacingS),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: SafeGoogleFont(
              'DM Sans',
              fontSize: sw * (kFontXS - 0.005),
              color: kSecondaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

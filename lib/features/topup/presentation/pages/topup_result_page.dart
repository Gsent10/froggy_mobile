import 'package:flutter/material.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/features/topup/presentation/pages/topup_page.dart';

class TopupResultPage extends StatelessWidget {
  const TopupResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as TopupResultArgs;
    final sw = context.screenWidth;
    final sh = context.screenHeight;

    final isSuccess = args.success;

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * kHorizontalPadding),
          child: Column(
            children: [
              SizedBox(height: sh * 0.08),

              _ResultIcon(success: isSuccess),

              SizedBox(height: sh * 0.04),

              Text(
                isSuccess ? 'Top-Up Successful!' : 'Top-Up Failed',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontM,
                  fontWeight: FontWeight.w700,
                  color: kBlackColor,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: sh * 0.012),

              Text(
                isSuccess
                    ? 'Your wallet has been credited successfully.'
                    : (args.errorMessage ??
                          'Your payment was declined. Please try again.'),
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  color: kSecondaryColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: sh * 0.05),

              _SummaryCard(args: args),

              const Spacer(),

              if (isSuccess) ...[
                SizedBox(
                  width: double.infinity,
                  height: sh * 0.065,
                  child: ElevatedButton(
                    onPressed: () {
                      // Pop back to the screen that launched top-up
                      // (typically home or wallet details)
                      Navigator.popUntil(
                        context,
                        (route) =>
                            route.settings.name == '/' ||
                            route.settings.name == '/home' ||
                            route.isFirst,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Back to Home',
                      style: SafeGoogleFont(
                        'DM Sans',
                        fontSize: sw * kFontXS,
                        fontWeight: FontWeight.w700,
                        color: kWhiteColor,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: sh * 0.065,
                  child: ElevatedButton(
                    onPressed: () {
                      // Go back to top-up form to retry
                      Navigator.pushReplacementNamed(context, '/topup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Try Again',
                      style: SafeGoogleFont(
                        'DM Sans',
                        fontSize: sw * kFontXS,
                        fontWeight: FontWeight.w700,
                        color: kWhiteColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: sh * kSpacingM),
                SizedBox(
                  width: double.infinity,
                  height: sh * 0.065,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                        (route) =>
                            route.settings.name == '/' ||
                            route.settings.name == '/home' ||
                            route.isFirst,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Back to Home',
                      style: SafeGoogleFont(
                        'DM Sans',
                        fontSize: sw * kFontXS,
                        fontWeight: FontWeight.w700,
                        color: kBlackColor,
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: sh * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultIcon extends StatefulWidget {
  final bool success;
  const _ResultIcon({required this.success});

  @override
  State<_ResultIcon> createState() => _ResultIconState();
}

class _ResultIconState extends State<_ResultIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final color = widget.success
        ? const Color(0xff1E7C47)
        : const Color(0xffE53935);
    final bgColor = color.withOpacity(0.1);
    final icon = widget.success ? Icons.check_rounded : Icons.close_rounded;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: sw * 0.28,
        height: sw * 0.28,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Center(
          child: Container(
            width: sw * 0.2,
            height: sw * 0.2,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: sw * 0.12, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final TopupResultArgs args;
  const _SummaryCard({required this.args});

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

    final rows = <(String, String)>[
      ('Amount', '${args.currencySymbol}${_formatAmount(args.amount)}'),
      if (args.wallet != null)
        ('Wallet', '${args.wallet!.currencyCode} Wallet'),
      if (args.reference.isNotEmpty) ('Reference', args.reference),
      ('Status', args.success ? 'Successful' : 'Failed'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.05),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final i = entry.key;
          final row = entry.value;
          final isLast = i == rows.length - 1;
          final isStatus = row.$1 == 'Status';

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: sw * 0.025),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.$1,
                      style: SafeGoogleFont(
                        'DM Sans',
                        fontSize: sw * kFontXS,
                        color: kSecondaryColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (isStatus)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: args.success
                              ? const Color(0xff1E7C47).withOpacity(0.1)
                              : const Color(0xffE53935).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          row.$2,
                          style: SafeGoogleFont(
                            'DM Sans',
                            fontSize: sw * (kFontXS - 0.005),
                            fontWeight: FontWeight.w600,
                            color: args.success
                                ? const Color(0xff1E7C47)
                                : const Color(0xffE53935),
                          ),
                        ),
                      )
                    else
                      Text(
                        row.$2,
                        style: SafeGoogleFont(
                          'DM Sans',
                          fontSize: sw * kFontXS,
                          fontWeight: FontWeight.w600,
                          color: kBlackColor,
                        ),
                      ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.08),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

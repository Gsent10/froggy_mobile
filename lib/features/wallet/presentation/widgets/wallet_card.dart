import 'package:flutter/material.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';

class WalletTheme {
  final Color cardColor;
  final Color accentColor;
  final String flagAsset;
  final String countryName;

  const WalletTheme({
    required this.cardColor,
    required this.accentColor,
    required this.flagAsset,
    required this.countryName,
  });
}

const walletThemes = <String, WalletTheme>{
  'GBP': WalletTheme(
    cardColor: Color(0xff003078),
    accentColor: Color(0xffCF142B),
    flagAsset: 'assets/flags/GB.png',
    countryName: 'United Kingdom',
  ),
  'NGN': WalletTheme(
    cardColor: Color(0xff1E7C47),
    accentColor: Color(0xffA8E6C3),
    flagAsset: 'assets/flags/NG.png',
    countryName: 'Nigeria',
  ),
  'USD': WalletTheme(
    cardColor: Color(0xff1A3A5C),
    accentColor: Color(0xffB22234),
    flagAsset: 'assets/flags/US.png',
    countryName: 'United States',
  ),
  'GHS': WalletTheme(
    cardColor: Color(0xff8B0000),
    accentColor: Color(0xffFCD116),
    flagAsset: 'assets/flags/GH.png',
    countryName: 'Ghana',
  ),
  'KES': WalletTheme(
    cardColor: Color(0xff1a1a1a),
    accentColor: Color(0xffBB0000),
    flagAsset: 'assets/flags/KE.png',
    countryName: 'Kenya',
  ),
};

WalletTheme themeFor(String currencyCode) =>
    walletThemes[currencyCode.toUpperCase()] ??
    const WalletTheme(
      cardColor: Color(0xff1a1a1a),
      accentColor: Color(0xff444444),
      flagAsset: 'assets/flags/NG.png',
      countryName: 'Unknown',
    );

class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.cardWidth,
    required this.cardHeight,
    required this.wallet,
    required this.theme,
    required this.visibilityNotifier,
    this.showDetailsLink = true,
  });

  final double cardWidth;
  final double cardHeight;
  final Wallet? wallet;
  final WalletTheme theme;
  final ValueNotifier<bool> visibilityNotifier;
  final bool showDetailsLink;

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
                visible ? '$symbol${_formatAmount(balance)}' : '$symbol ••••••',
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

              if (showDetailsLink) ...[
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
            ],
          ),
        );
      },
    );
  }
}

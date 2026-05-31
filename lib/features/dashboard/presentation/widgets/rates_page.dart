import 'package:flutter/material.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/features/transfer/data/exchange_rates.dart';

class _CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final String flagAsset;
  final Color color;

  const _CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flagAsset,
    required this.color,
  });
}

const _currencies = [
  _CurrencyInfo(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    flagAsset: 'assets/flags/US.png',
    color: Color(0xff1A3A5C),
  ),
  _CurrencyInfo(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    flagAsset: 'assets/flags/GB.png',
    color: Color(0xff003078),
  ),
  _CurrencyInfo(
    code: 'NGN',
    symbol: '₦',
    name: 'Nigerian Naira',
    flagAsset: 'assets/flags/NG.png',
    color: Color(0xff1E7C47),
  ),
  _CurrencyInfo(
    code: 'GHS',
    symbol: 'GH₵',
    name: 'Ghanaian Cedi',
    flagAsset: 'assets/flags/GH.png',
    color: Color(0xff8B0000),
  ),
  _CurrencyInfo(
    code: 'KES',
    symbol: 'KSh',
    name: 'Kenyan Shilling',
    flagAsset: 'assets/flags/KE.png',
    color: Color(0xff1a1a1a),
  ),
];

_CurrencyInfo _infoFor(String code) => _currencies.firstWhere(
  (c) => c.code == code,
  orElse: () => _currencies.first,
);

class RatesPage extends StatefulWidget {
  const RatesPage({super.key});

  @override
  State<RatesPage> createState() => _RatesPageState();
}

class _RatesPageState extends State<RatesPage> {
  String _baseCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final sh = context.screenHeight;
    final baseInfo = _infoFor(_baseCurrency);

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sw * kHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: sh * kSpacingXL),

              Text(
                'Exchange Rates',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontL,
                  fontWeight: FontWeight.w700,
                  color: kBlackColor,
                ),
              ),
              SizedBox(height: sh * 0.005),
              Text(
                'Fixed test rates · 1 ${baseInfo.name} equals:',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * (kFontXS - 0.003),
                  color: kSecondaryColor,
                ),
              ),

              SizedBox(height: sh * kSpacingL),

              Text(
                'Base Currency',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  fontWeight: FontWeight.w600,
                  color: kBlackColor,
                ),
              ),
              SizedBox(height: sh * 0.012),
              SizedBox(
                height: sw * 0.13,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _currencies.length,
                  separatorBuilder: (_, __) => SizedBox(width: sw * 0.025),
                  itemBuilder: (context, i) {
                    final c = _currencies[i];
                    final isSelected = c.code == _baseCurrency;
                    return GestureDetector(
                      onTap: () => setState(() => _baseCurrency = c.code),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04,
                          vertical: sw * 0.025,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? c.color : kWhiteColor,
                          borderRadius: BorderRadius.circular(sw * 0.03),
                          border: Border.all(
                            color: isSelected
                                ? c.color
                                : Colors.grey.withOpacity(0.2),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipOval(
                              child: Image.asset(
                                c.flagAsset,
                                width: sw * 0.055,
                                height: sw * 0.055,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.flag_rounded,
                                  size: sw * 0.055,
                                  color: isSelected
                                      ? kWhiteColor
                                      : kSecondaryColor,
                                ),
                              ),
                            ),
                            SizedBox(width: sw * 0.02),
                            Text(
                              c.code,
                              style: SafeGoogleFont(
                                'DM Sans',
                                fontSize: sw * kFontXS,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? kWhiteColor : kBlackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: sh * kSpacingL),

              _HeroCard(info: baseInfo),

              SizedBox(height: sh * kSpacingL),

              Text(
                'Conversion rates',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  fontWeight: FontWeight.w600,
                  color: kBlackColor,
                ),
              ),
              SizedBox(height: sh * 0.012),
              Container(
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _currencies
                      .where((c) => c.code != _baseCurrency)
                      .length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.withOpacity(0.08),
                  ),
                  itemBuilder: (context, i) {
                    final targets = _currencies
                        .where((c) => c.code != _baseCurrency)
                        .toList();
                    return _RateRow(base: baseInfo, target: targets[i]);
                  },
                ),
              ),

              SizedBox(height: sh * kSpacingL),

              Text(
                'Full rate matrix',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  fontWeight: FontWeight.w600,
                  color: kBlackColor,
                ),
              ),
              SizedBox(height: sh * 0.012),
              _RateMatrix(),

              SizedBox(height: sh * kSpacingL),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final _CurrencyInfo info;
  const _HeroCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final sh = context.screenHeight;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.05),
      decoration: BoxDecoration(
        color: info.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: sw * 0.14,
            height: sw * 0.14,
            decoration: BoxDecoration(
              color: kWhiteColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: ClipOval(
                child: Image.asset(
                  info.flagAsset,
                  width: sw * 0.1,
                  height: sw * 0.1,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.flag_rounded,
                    size: sw * 0.08,
                    color: kWhiteColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: sw * 0.04),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1 ${info.code}',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontL,
                  fontWeight: FontWeight.w700,
                  color: kWhiteColor,
                ),
              ),
              SizedBox(height: sh * 0.004),
              Text(
                info.name,
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  color: kWhiteColor.withOpacity(0.75),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            info.symbol,
            style: SafeGoogleFont(
              'DM Sans',
              fontSize: sw * 0.12,
              fontWeight: FontWeight.w700,
              color: kWhiteColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  final _CurrencyInfo base;
  final _CurrencyInfo target;

  const _RateRow({required this.base, required this.target});

  String _formatRate(double rate) {
    if (rate >= 1000) {
      final parts = rate.toStringAsFixed(2).split('.');
      final intPart = parts[0].replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[0]},',
      );
      return '$intPart.${parts[1]}';
    }
    if (rate < 0.01) return rate.toStringAsFixed(6);
    return rate.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final sh = context.screenHeight;
    final rate = ExchangeRates.getRate(base.code, target.code);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.04,
        vertical: sh * 0.018,
      ),
      child: Row(
        children: [
          // Flag
          ClipOval(
            child: Image.asset(
              target.flagAsset,
              width: sw * 0.1,
              height: sw * 0.1,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: sw * 0.1,
                height: sw * 0.1,
                decoration: BoxDecoration(
                  color: target.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flag_rounded,
                  size: sw * 0.05,
                  color: target.color,
                ),
              ),
            ),
          ),
          SizedBox(width: sw * 0.03),

          // Currency name + code
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.name,
                  style: SafeGoogleFont(
                    'DM Sans',
                    fontSize: sw * kFontXS,
                    fontWeight: FontWeight.w600,
                    color: kBlackColor,
                  ),
                ),
                SizedBox(height: sh * 0.003),
                Text(
                  target.code,
                  style: SafeGoogleFont(
                    'DM Sans',
                    fontSize: sw * (kFontXS - 0.005),
                    color: kSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Rate
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${target.symbol}${_formatRate(rate)}',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  fontWeight: FontWeight.w700,
                  color: kBlackColor,
                ),
              ),
              SizedBox(height: sh * 0.003),
              Text(
                'per 1 ${base.code}',
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * (kFontXS - 0.007),
                  color: kSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RateMatrix extends StatelessWidget {
  const _RateMatrix();

  String _formatCell(double rate) {
    if (rate == 1.0) return '—';
    if (rate >= 100) return rate.toStringAsFixed(0);
    if (rate >= 1) return rate.toStringAsFixed(2);
    return rate.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final cellW = (sw * (1 - 2 * kHorizontalPadding)) / 6;

    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                _MatrixCell(
                  width: cellW,
                  text: '↓ \\ →',
                  isHeader: true,
                  isCorner: true,
                ),
                ..._currencies.map(
                  (c) => _MatrixCell(
                    width: cellW,
                    text: c.code,
                    isHeader: true,
                    color: c.color,
                  ),
                ),
              ],
            ),
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),

            // Data rows
            ..._currencies.asMap().entries.map((fromEntry) {
              final from = fromEntry.value;
              final isLast = fromEntry.key == _currencies.length - 1;

              return Column(
                children: [
                  Row(
                    children: [
                      // Row header
                      _MatrixCell(
                        width: cellW,
                        text: from.code,
                        isHeader: true,
                        color: from.color,
                      ),
                      // Rate cells
                      ..._currencies.map((to) {
                        final isSelf = from.code == to.code;
                        final rate = ExchangeRates.getRate(from.code, to.code);
                        return _MatrixCell(
                          width: cellW,
                          text: _formatCell(rate),
                          isSelf: isSelf,
                        );
                      }),
                    ],
                  ),
                  if (!isLast)
                    Divider(height: 1, color: Colors.grey.withOpacity(0.08)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MatrixCell extends StatelessWidget {
  final double width;
  final String text;
  final bool isHeader;
  final bool isCorner;
  final bool isSelf;
  final Color? color;

  const _MatrixCell({
    required this.width,
    required this.text,
    this.isHeader = false,
    this.isCorner = false,
    this.isSelf = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;

    Color bgColor = kWhiteColor;
    Color textColor = kBlackColor;

    if (isCorner) {
      bgColor = const Color(0xffF2F4F8);
      textColor = kSecondaryColor;
    } else if (isHeader && color != null) {
      bgColor = color!.withOpacity(0.08);
      textColor = color!;
    } else if (isSelf) {
      bgColor = const Color(0xffF2F4F8);
      textColor = kSecondaryColor;
    }

    return Container(
      width: width,
      padding: EdgeInsets.symmetric(vertical: sw * 0.03),
      color: bgColor,
      alignment: Alignment.center,
      child: Text(
        text,
        style: SafeGoogleFont(
          'DM Sans',
          fontSize: sw * (kFontXS - 0.008),
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          color: textColor,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

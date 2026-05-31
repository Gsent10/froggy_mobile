import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/core/widgets/loading.dart';
import 'package:froggy_mobile/features/wallet/bloc/wallet_bloc.dart';

// Wallet theme data class — defined here or imported from your themes file
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

class AddWalletPage extends StatefulWidget {
  const AddWalletPage({super.key});

  @override
  State<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  String? _selectedCurrencyCode;

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final sh = context.screenHeight;

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state.createStatus == WalletCreateStatus.success) {
          context.read<WalletBloc>().add(ResetWalletCreateStatus());
          Navigator.pop(context, true); // pass true so list page can refresh
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wallet created successfully!'),
              backgroundColor: Color(0xff1E7C47),
            ),
          );
        }
      },
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          final isLoading = state.createStatus == WalletCreateStatus.loading;

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
                    'Create New Wallet',
                    style: SafeGoogleFont(
                      'DM Sans',
                      fontSize: sw * kFontS,
                      fontWeight: FontWeight.w700,
                      color: kBlackColor,
                    ),
                  ),
                  centerTitle: true,
                ),
                body: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * kHorizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: sh * 0.03),
                      Text(
                        'Select Currency',
                        style: SafeGoogleFont(
                          'DM Sans',
                          fontSize: sw * kFontXS,
                          fontWeight: FontWeight.w600,
                          color: kBlackColor,
                        ),
                      ),
                      SizedBox(height: sh * 0.012),
                      _CurrencyDropdown(
                        selectedCode: _selectedCurrencyCode,
                        onChanged: (code) {
                          setState(() => _selectedCurrencyCode = code);
                        },
                      ),
                      // Preview card
                      if (_selectedCurrencyCode != null) ...[
                        SizedBox(height: sh * 0.04),
                        _WalletPreviewCard(
                          currencyCode: _selectedCurrencyCode!,
                          theme: walletThemes[_selectedCurrencyCode]!,
                        ),
                      ],
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: sh * 0.065,
                        child: ElevatedButton(
                          onPressed:
                              (_selectedCurrencyCode == null || isLoading)
                              ? null
                              : () {
                                  context.read<WalletBloc>().add(
                                    CreateWallet(_selectedCurrencyCode!),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            disabledBackgroundColor: kPrimaryColor.withOpacity(
                              0.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Create Wallet',
                            style: SafeGoogleFont(
                              'DM Sans',
                              fontSize: sw * kFontXS,
                              fontWeight: FontWeight.w700,
                              color: kWhiteColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: sh * 0.04),
                    ],
                  ),
                ),
              ),
              if (isLoading) const Loading(),
            ],
          );
        },
      ),
    );
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final String? selectedCode;
  final ValueChanged<String?> onChanged;

  const _CurrencyDropdown({
    required this.selectedCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCode,
          isExpanded: true,
          hint: Text(
            'Choose a currency',
            style: SafeGoogleFont(
              'DM Sans',
              fontSize: sw * kFontXS,
              color: kSecondaryColor,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: kSecondaryColor,
          ),
          items: walletThemes.entries.map((entry) {
            final code = entry.key;
            final theme = entry.value;
            return DropdownMenuItem<String>(
              value: code,
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      theme.flagAsset,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: theme.cardColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flag_rounded,
                          size: 16,
                          color: theme.cardColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      theme.countryName,
                      style: SafeGoogleFont(
                        'DM Sans',
                        fontSize: sw * kFontXS,
                        fontWeight: FontWeight.w500,
                        color: kBlackColor,
                      ),
                    ),
                  ),
                  Text(
                    code,
                    style: SafeGoogleFont(
                      'DM Sans',
                      fontSize: sw * (kFontXS - 0.005),
                      color: kSecondaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _WalletPreviewCard extends StatelessWidget {
  final String currencyCode;
  final WalletTheme theme;

  const _WalletPreviewCard({required this.currencyCode, required this.theme});

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;

    return Container(
      width: double.infinity,
      height: sw * 0.5,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(sw * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                theme.countryName,
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontXS,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              ClipOval(
                child: Image.asset(
                  theme.flagAsset,
                  width: sw * 0.09,
                  height: sw * 0.09,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: sw * 0.09,
                    height: sw * 0.09,
                    decoration: BoxDecoration(
                      color: theme.accentColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '0.00',
            style: SafeGoogleFont(
              'DM Sans',
              fontSize: sw * 0.08,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: sw * 0.01),
          Text(
            currencyCode,
            style: SafeGoogleFont(
              'DM Sans',
              fontSize: sw * kFontXS,
              fontWeight: FontWeight.w500,
              color: theme.accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

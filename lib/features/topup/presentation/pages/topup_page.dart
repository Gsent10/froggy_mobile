import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/core/widgets/loading.dart';
import 'package:froggy_mobile/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';
import 'package:froggy_mobile/features/topup/bloc/topup_bloc.dart';
import 'package:uuid/uuid.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final TextEditingController _amountController = TextEditingController();
  Wallet? _selectedWallet;
  String _selectedPaymentMethod = 'card';
  final String _idempotencyKey = const Uuid().v4();

  static const _paymentMethods = [
    (value: 'card', label: 'Debit Card', icon: Icons.credit_card_rounded),
    (
      value: 'bank_transfer',
      label: 'Bank Transfer',
      icon: Icons.account_balance_rounded,
    ),
    (value: 'ussd', label: 'USSD', icon: Icons.dialpad_rounded),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final sh = context.screenHeight;

    return BlocListener<TopupBloc, TopupState>(
      listener: (context, state) {
        if (state.status == TopupStatus.success) {
          // Refresh dashboard so balances update
          context.read<DashboardBloc>().add(FetchDashboardData());
          Navigator.pushReplacementNamed(
            context,
            '/topup-result',
            arguments: TopupResultArgs(
              success: true,
              wallet: state.updatedWallet,
              reference: state.transactionReference ?? '',
              amount: double.tryParse(_amountController.text) ?? 0,
              currencySymbol: _selectedWallet?.currencySymbol ?? '',
            ),
          );
          context.read<TopupBloc>().add(ResetTopup());
        } else if (state.status == TopupStatus.failed ||
            state.status == TopupStatus.error) {
          Navigator.pushReplacementNamed(
            context,
            '/topup-result',
            arguments: TopupResultArgs(
              success: false,
              wallet: state.updatedWallet,
              reference: '',
              amount: double.tryParse(_amountController.text) ?? 0,
              currencySymbol: _selectedWallet?.currencySymbol ?? '',
              errorMessage: state.errorMessage,
            ),
          );
          context.read<TopupBloc>().add(ResetTopup());
        }
      },
      child: BlocBuilder<TopupBloc, TopupState>(
        builder: (context, topupState) {
          final isLoading = topupState.status == TopupStatus.loading;

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
                    'Top Up',
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
                  builder: (context, dashState) {
                    final wallets = dashState.data?.wallets ?? [];

                    // Auto-select first wallet if none selected yet
                    if (_selectedWallet == null && wallets.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() => _selectedWallet = wallets.first);
                      });
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * kHorizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: sh * 0.03),

                          // ── Wallet selector ──────────────────────────────
                          Text(
                            'Select Wallet',
                            style: SafeGoogleFont(
                              'DM Sans',
                              fontSize: sw * kFontXS,
                              fontWeight: FontWeight.w600,
                              color: kBlackColor,
                            ),
                          ),
                          SizedBox(height: sh * 0.012),
                          _WalletDropdown(
                            wallets: wallets,
                            selected: _selectedWallet,
                            onChanged: (w) =>
                                setState(() => _selectedWallet = w),
                          ),

                          SizedBox(height: sh * 0.03),

                          // ── Amount input ─────────────────────────────────
                          Text(
                            'Amount',
                            style: SafeGoogleFont(
                              'DM Sans',
                              fontSize: sw * kFontXS,
                              fontWeight: FontWeight.w600,
                              color: kBlackColor,
                            ),
                          ),
                          SizedBox(height: sh * 0.012),
                          _AmountField(
                            controller: _amountController,
                            currencySymbol:
                                _selectedWallet?.currencySymbol ?? '',
                          ),

                          SizedBox(height: sh * 0.03),

                          // ── Quick amounts ────────────────────────────────
                          _QuickAmounts(
                            onSelect: (amount) {
                              _amountController.text = amount.toStringAsFixed(
                                0,
                              );
                            },
                          ),

                          SizedBox(height: sh * 0.03),

                          // ── Payment method ───────────────────────────────
                          Text(
                            'Payment Method',
                            style: SafeGoogleFont(
                              'DM Sans',
                              fontSize: sw * kFontXS,
                              fontWeight: FontWeight.w600,
                              color: kBlackColor,
                            ),
                          ),
                          SizedBox(height: sh * 0.012),
                          ...(_paymentMethods.map((method) {
                            final isSelected =
                                _selectedPaymentMethod == method.value;
                            return GestureDetector(
                              onTap: () => setState(
                                () => _selectedPaymentMethod = method.value,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: EdgeInsets.only(bottom: sh * kSpacingS),
                                padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.04,
                                  vertical: sh * 0.018,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? kPrimaryColor.withOpacity(0.06)
                                      : kWhiteColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? kPrimaryColor
                                        : Colors.grey.withOpacity(0.15),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      method.icon,
                                      size: sw * 0.055,
                                      color: isSelected
                                          ? kPrimaryColor
                                          : kSecondaryColor,
                                    ),
                                    SizedBox(width: sw * 0.035),
                                    Text(
                                      method.label,
                                      style: SafeGoogleFont(
                                        'DM Sans',
                                        fontSize: sw * kFontXS,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? kPrimaryColor
                                            : kBlackColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: sw * 0.055,
                                        color: kPrimaryColor,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          })),

                          SizedBox(height: sh * 0.04),

                          // ── Submit ────────────────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: sh * 0.065,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                disabledBackgroundColor: kPrimaryColor
                                    .withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Top Up Now',
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
                    );
                  },
                ),
              ),
              if (isLoading) const Loading(),
            ],
          );
        },
      ),
    );
  }

  void _submit() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (_selectedWallet == null) {
      _showError('Please select a wallet.');
      return;
    }
    if (amount == null || amount < 1) {
      _showError('Please enter a valid amount (minimum 1).');
      return;
    }

    context.read<TopupBloc>().add(
      SubmitTopup(
        currencyCode: _selectedWallet!.currencyCode,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        idempotencyKey: _idempotencyKey,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }
}

// ─── Wallet dropdown ──────────────────────────────────────────────────────────

class _WalletDropdown extends StatelessWidget {
  final List<Wallet> wallets;
  final Wallet? selected;
  final ValueChanged<Wallet?> onChanged;

  const _WalletDropdown({
    required this.wallets,
    required this.selected,
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
        child: DropdownButton<Wallet>(
          value: selected,
          isExpanded: true,
          hint: Text(
            'Choose a wallet',
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
          items: wallets.map((wallet) {
            return DropdownMenuItem<Wallet>(
              value: wallet,
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      getFlagPath(wallet.currencyCode),
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          size: 16,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${wallet.currencyCode} Wallet',
                      style: SafeGoogleFont(
                        'DM Sans',
                        fontSize: sw * kFontXS,
                        fontWeight: FontWeight.w500,
                        color: kBlackColor,
                      ),
                    ),
                  ),
                  Text(
                    '${wallet.currencySymbol}${wallet.balance.toStringAsFixed(2)}',
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

// ─── Amount field ─────────────────────────────────────────────────────────────

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String currencySymbol;

  const _AmountField({required this.controller, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;

    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          if (currencySymbol.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: sw * 0.04),
              child: Text(
                currencySymbol,
                style: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontS,
                  fontWeight: FontWeight.w700,
                  color: kBlackColor,
                ),
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: SafeGoogleFont(
                'DM Sans',
                fontSize: sw * kFontS,
                fontWeight: FontWeight.w700,
                color: kBlackColor,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: SafeGoogleFont(
                  'DM Sans',
                  fontSize: sw * kFontS,
                  fontWeight: FontWeight.w700,
                  color: kSecondaryColor.withOpacity(0.4),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick amount chips ───────────────────────────────────────────────────────

class _QuickAmounts extends StatelessWidget {
  final ValueChanged<double> onSelect;

  const _QuickAmounts({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    const amounts = [500.0, 1000.0, 5000.0, 10000.0];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: amounts.map((amount) {
        return GestureDetector(
          onTap: () => onSelect(amount),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: 10),
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: Text(
              amount >= 1000
                  ? '${(amount / 1000).toStringAsFixed(0)}k'
                  : amount.toStringAsFixed(0),
              style: SafeGoogleFont(
                'DM Sans',
                fontSize: sw * kFontXS,
                fontWeight: FontWeight.w600,
                color: kBlackColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Result args ──────────────────────────────────────────────────────────────

class TopupResultArgs {
  final bool success;
  final Wallet? wallet;
  final String reference;
  final double amount;
  final String currencySymbol;
  final String? errorMessage;

  const TopupResultArgs({
    required this.success,
    required this.wallet,
    required this.reference,
    required this.amount,
    required this.currencySymbol,
    this.errorMessage,
  });
}

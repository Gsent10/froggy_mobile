import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/core/widgets/loading.dart';
import 'package:froggy_mobile/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';
import 'package:froggy_mobile/features/transfer/bloc/transfer_bloc.dart';
import 'package:froggy_mobile/features/transfer/data/exchange_rates.dart';
import 'package:uuid/uuid.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final TextEditingController _amountController = TextEditingController();
  Wallet? _fromWallet;
  Wallet? _toWallet;
  final String _idempotencyKey = const Uuid().v4();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _fromWallet != null &&
      _toWallet != null &&
      _fromWallet!.id != _toWallet!.id &&
      (_amountController.text.isNotEmpty) &&
      (double.tryParse(_amountController.text) ?? 0) > 0;

  void _submit(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    if (amount > (_fromWallet?.balance ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance in source wallet')),
      );
      return;
    }

    context.read<TransferBloc>().add(
      SubmitTransfer(
        fromWalletId: _fromWallet!.id,
        toWalletId: _toWallet!.id,
        amount: amount,
        idempotencyKey: _idempotencyKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final sh = context.screenHeight;

    return BlocListener<TransferBloc, TransferState>(
      listener: (context, state) {
        if (state.status == TransferStatus.success) {
          context.read<DashboardBloc>().add(FetchDashboardData());
          Navigator.pushReplacementNamed(
            context,
            '/transfer-result',
            arguments: TransferResultArgs(
              success: true,
              fromWallet: _fromWallet,
              toWallet: _toWallet,
              reference: state.transactionReference ?? '',
              amount: double.tryParse(_amountController.text) ?? 0,
            ),
          );
          context.read<TransferBloc>().add(ResetTransfer());
        } else if (state.status == TransferStatus.failed ||
            state.status == TransferStatus.error) {
          Navigator.pushReplacementNamed(
            context,
            '/transfer-result',
            arguments: TransferResultArgs(
              success: false,
              fromWallet: _fromWallet,
              toWallet: _toWallet,
              reference: '',
              amount: double.tryParse(_amountController.text) ?? 0,
              errorMessage: state.errorMessage,
            ),
          );
          context.read<TransferBloc>().add(ResetTransfer());
        }
      },
      child: BlocBuilder<TransferBloc, TransferState>(
        builder: (context, transferState) {
          final isLoading = transferState.status == TransferStatus.loading;

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
                    'Transfer',
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

                    if (_fromWallet == null && wallets.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _fromWallet = wallets.first;
                          _toWallet = wallets.length > 1 ? wallets[1] : null;
                        });
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

                          // ── From wallet ───────────────────────────────────
                          Text(
                            'From Wallet',
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
                            selected: _fromWallet,
                            excludeWallet: _toWallet,
                            hint: 'Select source wallet',
                            onChanged: (w) {
                              setState(() {
                                _fromWallet = w;
                                // If to-wallet is the same, clear it
                                if (_toWallet?.id == w?.id) _toWallet = null;
                              });
                            },
                          ),

                          SizedBox(height: sh * 0.02),

                          // ── Swap icon ─────────────────────────────────────
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  final temp = _fromWallet;
                                  _fromWallet = _toWallet;
                                  _toWallet = temp;
                                });
                              },
                              child: Container(
                                width: sw * 0.11,
                                height: sw * 0.11,
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: kPrimaryColor.withOpacity(0.2),
                                  ),
                                ),
                                child: Icon(
                                  Icons.swap_vert_rounded,
                                  color: kPrimaryColor,
                                  size: sw * 0.055,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: sh * 0.02),

                          // ── To wallet ─────────────────────────────────────
                          Text(
                            'To Wallet',
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
                            selected: _toWallet,
                            excludeWallet: _fromWallet,
                            hint: 'Select destination wallet',
                            onChanged: (w) {
                              setState(() {
                                _toWallet = w;
                                if (_fromWallet?.id == w?.id)
                                  _fromWallet = null;
                              });
                            },
                          ),

                          SizedBox(height: sh * 0.03),

                          // ── Exchange rate preview ─────────────────────────
                          if (_fromWallet != null && _toWallet != null)
                            _ExchangeRatePreview(
                              fromWallet: _fromWallet!,
                              toWallet: _toWallet!,
                              amount:
                                  double.tryParse(_amountController.text) ?? 1,
                            ),

                          SizedBox(height: sh * 0.03),

                          // ── Amount ────────────────────────────────────────
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
                            currencySymbol: _fromWallet?.currencySymbol ?? '',
                            onChanged: (_) => setState(() {}),
                          ),

                          // ── Available balance hint ────────────────────────
                          if (_fromWallet != null) ...[
                            SizedBox(height: sh * 0.008),
                            Text(
                              'Available: ${_fromWallet!.currencySymbol}${_fromWallet!.balance.toStringAsFixed(2)}',
                              style: SafeGoogleFont(
                                'DM Sans',
                                fontSize: sw * (kFontXS - 0.005),
                                color: kSecondaryColor,
                              ),
                            ),
                          ],

                          SizedBox(height: sh * 0.04),

                          // ── Submit button ─────────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: sh * 0.065,
                            child: ElevatedButton(
                              onPressed: _canSubmit && !isLoading
                                  ? () => _submit(context)
                                  : null,
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
                                'Transfer',
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

              // ── Full-screen loader ────────────────────────────────────────
              if (isLoading) const Loading(),
            ],
          );
        },
      ),
    );
  }
}

// ─── Wallet dropdown ──────────────────────────────────────────────────────────

class _WalletDropdown extends StatelessWidget {
  final List<Wallet> wallets;
  final Wallet? selected;
  final Wallet? excludeWallet;
  final String hint;
  final ValueChanged<Wallet?> onChanged;

  const _WalletDropdown({
    required this.wallets,
    required this.selected,
    required this.onChanged,
    required this.hint,
    this.excludeWallet,
  });

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final filtered = wallets.where((w) => w.id != excludeWallet?.id).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Wallet>(
          value: filtered.any((w) => w.id == selected?.id) ? selected : null,
          isExpanded: true,
          hint: Text(
            hint,
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
          items: filtered.map((wallet) {
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
  final ValueChanged<String>? onChanged;

  const _AmountField({
    required this.controller,
    required this.currencySymbol,
    this.onChanged,
  });

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
              onChanged: onChanged,
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

// ─── Exchange rate preview ────────────────────────────────────────────────────

class _ExchangeRatePreview extends StatelessWidget {
  final Wallet fromWallet;
  final Wallet toWallet;
  final double amount;

  const _ExchangeRatePreview({
    required this.fromWallet,
    required this.toWallet,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;

    final rate = ExchangeRates.getRate(
      fromWallet.currencyCode,
      toWallet.currencyCode,
    );
    final convertedAmount = amount > 0 ? amount * rate : rate;
    final displayAmount = amount > 0 ? amount : 1;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.04,
        vertical: sw * 0.035,
      ),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.currency_exchange_rounded,
            size: sw * 0.045,
            color: kPrimaryColor,
          ),
          SizedBox(width: sw * 0.025),
          Expanded(
            child: Text(
              '${fromWallet.currencySymbol}${displayAmount.toStringAsFixed(2)} '
              '${fromWallet.currencyCode} = '
              '${toWallet.currencySymbol}${convertedAmount.toStringAsFixed(2)} '
              '${toWallet.currencyCode}',
              style: SafeGoogleFont(
                'DM Sans',
                fontSize: sw * (kFontXS - 0.003),
                color: kPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Result args ──────────────────────────────────────────────────────────────

class TransferResultArgs {
  final bool success;
  final Wallet? fromWallet;
  final Wallet? toWallet;
  final String reference;
  final double amount;
  final String? errorMessage;

  const TransferResultArgs({
    required this.success,
    required this.fromWallet,
    required this.toWallet,
    required this.reference,
    required this.amount,
    this.errorMessage,
  });
}

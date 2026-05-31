part of 'topup_bloc.dart';

enum TopupStatus { initial, loading, success, failed, error }

class TopupState {
  final TopupStatus status;
  final String? errorMessage;
  final Wallet? updatedWallet;
  final String? transactionReference;

  const TopupState({
    this.status = TopupStatus.initial,
    this.errorMessage,
    this.updatedWallet,
    this.transactionReference,
  });

  TopupState copyWith({
    TopupStatus? status,
    String? errorMessage,
    Wallet? updatedWallet,
    String? transactionReference,
  }) {
    return TopupState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      updatedWallet: updatedWallet ?? this.updatedWallet,
      transactionReference: transactionReference ?? this.transactionReference,
    );
  }
}

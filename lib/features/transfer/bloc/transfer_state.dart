part of 'transfer_bloc.dart';

enum TransferStatus { initial, loading, success, failed, error }

class TransferState {
  final TransferStatus status;
  final String? transactionReference;
  final String? errorMessage;
  final Wallet? updatedFromWallet;

  const TransferState({
    this.status = TransferStatus.initial,
    this.transactionReference,
    this.errorMessage,
    this.updatedFromWallet,
  });

  TransferState copyWith({
    TransferStatus? status,
    String? transactionReference,
    String? errorMessage,
    Wallet? updatedFromWallet,
  }) {
    return TransferState(
      status: status ?? this.status,
      transactionReference: transactionReference ?? this.transactionReference,
      errorMessage: errorMessage ?? this.errorMessage,
      updatedFromWallet: updatedFromWallet ?? this.updatedFromWallet,
    );
  }
}

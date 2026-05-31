part of 'transfer_bloc.dart';

sealed class TransferEvent {}

class SubmitTransfer extends TransferEvent {
  final int fromWalletId;
  final int toWalletId;
  final double amount;
  final String idempotencyKey;

  SubmitTransfer({
    required this.fromWalletId,
    required this.toWalletId,
    required this.amount,
    required this.idempotencyKey,
  });
}

class ResetTransfer extends TransferEvent {}

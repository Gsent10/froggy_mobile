part of 'wallet_bloc.dart';

abstract class WalletEvent {}

class FetchWalletDetails extends WalletEvent {
  final int walletId;
  FetchWalletDetails(this.walletId);
}

class CreateWallet extends WalletEvent {
  final String currencyCode;
  CreateWallet(this.currencyCode);
}

class ResetWalletCreateStatus extends WalletEvent {}

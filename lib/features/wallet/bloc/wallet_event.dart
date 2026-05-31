part of 'wallet_bloc.dart';

abstract class WalletEvent {}

class FetchWalletDetails extends WalletEvent {
  final int walletId;
  FetchWalletDetails(this.walletId);
}

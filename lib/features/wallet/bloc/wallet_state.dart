part of 'wallet_bloc.dart';

enum WalletStatus { initial, loading, loaded, error }

class WalletState {
  final WalletStatus status;
  final Wallet? wallet;
  final List<Activity> activities;
  final String? errorMessage;

  WalletState({
    this.status = WalletStatus.initial,
    this.wallet,
    this.activities = const [],
    this.errorMessage,
  });

  WalletState copyWith({
    WalletStatus? status,
    Wallet? wallet,
    List<Activity>? activities,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      activities: activities ?? this.activities,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

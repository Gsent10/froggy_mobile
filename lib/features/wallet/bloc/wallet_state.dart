part of 'wallet_bloc.dart';

enum WalletStatus { initial, loading, loaded, error }

enum WalletCreateStatus { idle, loading, success, error }

class WalletState {
  final WalletStatus status;
  final Wallet? wallet;
  final List<Log> logs;
  final String? errorMessage;

  // Create wallet fields
  final WalletCreateStatus createStatus;
  final Wallet? createdWallet;
  final String? createErrorMessage;

  WalletState({
    this.status = WalletStatus.initial,
    this.wallet,
    this.logs = const [],
    this.errorMessage,
    this.createStatus = WalletCreateStatus.idle,
    this.createdWallet,
    this.createErrorMessage,
  });

  WalletState copyWith({
    WalletStatus? status,
    Wallet? wallet,
    List<Log>? logs,
    String? errorMessage,
    WalletCreateStatus? createStatus,
    Wallet? createdWallet,
    String? createErrorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      logs: logs ?? this.logs,
      errorMessage: errorMessage ?? this.errorMessage,
      createStatus: createStatus ?? this.createStatus,
      createdWallet: createdWallet ?? this.createdWallet,
      createErrorMessage: createErrorMessage ?? this.createErrorMessage,
    );
  }
}

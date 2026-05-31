import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/network/api_endpoints.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';
import 'package:dio/dio.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final ApiEndpoints _apiEndpoints = ApiEndpoints();

  WalletBloc() : super(WalletState()) {
    on<FetchWalletDetails>((event, emit) async {
      emit(state.copyWith(status: WalletStatus.loading));

      await _apiEndpoints.safeSendRequest(
        request: (dio, headers) => dio.get(
          '${ApiEndpoints.WALLETS}/${event.walletId}',
          options: Options(headers: headers),
        ),
        onSuccess: (data) {
          final wallet = Wallet.fromJson(data['wallet'] ?? {});
          final logs = (data['logs'] as List? ?? [])
              .map((e) => Log.fromJson(e))
              .toList();

          emit(
            state.copyWith(
              status: WalletStatus.loaded,
              wallet: wallet,
              logs: logs,
            ),
          );
        },
        onError: (error) {
          emit(state.copyWith(status: WalletStatus.error, errorMessage: error));
        },
      );
    });

    on<CreateWallet>((event, emit) async {
      emit(state.copyWith(createStatus: WalletCreateStatus.loading));

      await _apiEndpoints.safeSendRequest(
        request: (dio, headers) => dio.post(
          ApiEndpoints.WALLETS,
          data: {'currency_code': event.currencyCode},
          options: Options(headers: headers),
        ),
        onSuccess: (data) {
          final wallet = Wallet.fromJson(data['wallet'] ?? {});
          emit(
            state.copyWith(
              createStatus: WalletCreateStatus.success,
              createdWallet: wallet,
            ),
          );
        },
        onError: (error) {
          emit(
            state.copyWith(
              createStatus: WalletCreateStatus.error,
              createErrorMessage: error,
            ),
          );
        },
      );
    });

    on<ResetWalletCreateStatus>((event, emit) {
      emit(
        state.copyWith(
          createStatus: WalletCreateStatus.idle,
          createErrorMessage: null,
        ),
      );
    });
  }
}

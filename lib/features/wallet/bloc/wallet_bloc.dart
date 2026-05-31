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
          final activities = (data['activities'] as List? ?? [])
              .map((e) => Activity.fromJson(e))
              .toList();

          emit(
            state.copyWith(
              status: WalletStatus.loaded,
              wallet: wallet,
              activities: activities,
            ),
          );
        },
        onError: (error) {
          emit(state.copyWith(status: WalletStatus.error, errorMessage: error));
        },
      );
    });
  }
}

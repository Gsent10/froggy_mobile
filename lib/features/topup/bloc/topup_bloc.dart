import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/network/api_endpoints.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';
import 'package:dio/dio.dart';

part 'topup_event.dart';
part 'topup_state.dart';

class TopupBloc extends Bloc<TopupEvent, TopupState> {
  final ApiEndpoints _apiEndpoints;

  TopupBloc({ApiEndpoints? apiEndpoints})
    : _apiEndpoints = apiEndpoints ?? ApiEndpoints(),
      super(const TopupState()) {
    on<SubmitTopup>((event, emit) async {
      emit(state.copyWith(status: TopupStatus.loading));

      await _apiEndpoints.safeSendRequest(
        request: (dio, headers) => dio.post(
          ApiEndpoints.TOPUP,
          data: {
            'currency_code': event.currencyCode,
            'amount': event.amount,
            'payment_method': event.paymentMethod,
            'idempotency_key': event.idempotencyKey,
          },
          options: Options(headers: headers),
        ),
        onSuccess: (data) {
          final wallet = Wallet.fromJson(data['wallet'] ?? {});
          final reference =
              (data['transaction'] as Map<String, dynamic>?)?['reference']
                  as String? ??
              '';

          emit(
            state.copyWith(
              status: TopupStatus.success,
              updatedWallet: wallet,
              transactionReference: reference,
            ),
          );
        },
        onError: (error) {
          final isDeclined =
              error.toLowerCase().contains('declined') ||
              error.toLowerCase().contains('failed');

          emit(
            state.copyWith(
              status: isDeclined ? TopupStatus.failed : TopupStatus.error,
              errorMessage: error,
            ),
          );
        },
      );
    });

    on<ResetTopup>((event, emit) {
      emit(const TopupState());
    });
  }
}

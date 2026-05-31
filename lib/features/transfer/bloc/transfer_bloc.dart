import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/network/api_endpoints.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';

part 'transfer_event.dart';
part 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final ApiEndpoints _apiEndpoints = ApiEndpoints();

  TransferBloc() : super(const TransferState()) {
    on<SubmitTransfer>((event, emit) async {
      emit(state.copyWith(status: TransferStatus.loading));

      await _apiEndpoints.safeSendRequest(
        request: (dio, headers) => dio.post(
          ApiEndpoints.TRANSFER,
          data: {
            'from_wallet_id': event.fromWalletId,
            'to_wallet_id': event.toWalletId,
            'amount': event.amount,
            'idempotency_key': event.idempotencyKey,
          },
          options: Options(headers: headers),
        ),
        onSuccess: (data) {
          final fromWalletData = data['from_wallet'];
          final updatedFromWallet = fromWalletData != null
              ? Wallet.fromJson(fromWalletData)
              : null;
          final reference = data['reference'] as String? ?? '';

          emit(
            state.copyWith(
              status: TransferStatus.success,
              transactionReference: reference,
              updatedFromWallet: updatedFromWallet,
            ),
          );
        },
        onError: (error) {
          final isInsufficient =
              error.toLowerCase().contains('insufficient') ||
              error.toLowerCase().contains('declined');

          emit(
            state.copyWith(
              status: isInsufficient
                  ? TransferStatus.failed
                  : TransferStatus.error,
              errorMessage: error,
            ),
          );
        },
      );
    });

    on<ResetTransfer>((event, emit) {
      emit(const TransferState());
    });
  }
}

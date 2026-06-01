import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:froggy_mobile/core/network/api_endpoints.dart';
import 'package:froggy_mobile/features/topup/bloc/topup_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockApiEndpoints extends Mock implements ApiEndpoints {}

void main() {
  late TopupBloc topupBloc;
  late MockApiEndpoints mockApiEndpoints;

  setUp(() {
    mockApiEndpoints = MockApiEndpoints();
    topupBloc = TopupBloc(apiEndpoints: mockApiEndpoints);
  });

  tearDown(() {
    topupBloc.close();
  });

  group('TopupBloc', () {
    final topupEvent = SubmitTopup(
      amount: 100.0,
      currencyCode: 'USD',
      paymentMethod: 'card',
      idempotencyKey: 'test-key',
    );

    blocTest<TopupBloc, TopupState>(
      'emits [loading, success] when top-up is successful',
      build: () {
        when(
          () => mockApiEndpoints.safeSendRequest(
            request: any(named: 'request'),
            onSuccess: any(named: 'onSuccess'),
            onError: any(named: 'onError'),
          ),
        ).thenAnswer((invocation) async {
          final onSuccess =
              invocation.namedArguments[#onSuccess]
                  as Function(Map<String, dynamic>);
          await onSuccess({
            'wallet': {
              'id': 1,
              'currency_code': 'USD',
              'balance': 600.0, // Updated balance
            },
            'transaction': {'reference': 'TX123'},
          });
        });
        return topupBloc;
      },
      act: (bloc) => bloc.add(topupEvent),
      expect: () => [
        predicate<TopupState>((state) => state.status == TopupStatus.loading),
        predicate<TopupState>((state) {
          return state.status == TopupStatus.success &&
              state.updatedWallet?.balance == 600.0 &&
              state.transactionReference == 'TX123';
        }),
      ],
    );

    blocTest<TopupBloc, TopupState>(
      'emits [loading, error] when top-up fails',
      build: () {
        when(
          () => mockApiEndpoints.safeSendRequest(
            request: any(named: 'request'),
            onSuccess: any(named: 'onSuccess'),
            onError: any(named: 'onError'),
          ),
        ).thenAnswer((invocation) async {
          final onError =
              invocation.namedArguments[#onError] as Function(String)?;
          if (onError != null) {
            await onError('Insufficient funds');
          }
        });
        return topupBloc;
      },
      act: (bloc) => bloc.add(topupEvent),
      expect: () => [
        predicate<TopupState>((state) => state.status == TopupStatus.loading),
        predicate<TopupState>(
          (state) =>
              state.status == TopupStatus.error &&
              state.errorMessage == 'Insufficient funds',
        ),
      ],
    );
  });
}

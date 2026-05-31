import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:froggy_mobile/core/network/api_endpoints.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ApiEndpoints _apiEndpoints = ApiEndpoints();

  HistoryBloc() : super(const HistoryState()) {
    on<FetchTransactions>(_onFetchTransactions);
    on<FetchActivity>(_onFetchActivity);
  }

  Future<void> _onFetchTransactions(
    FetchTransactions event,
    Emitter<HistoryState> emit,
  ) async {
    emit(
      state.copyWith(
        transactionsStatus: HistoryStatus.loading,
        transactions: [],
        transactionsError: '',
      ),
    );

    final List<Activity> allItems = [];
    int currentPage = 1;
    int lastPage = 1;

    do {
      bool pageError = false;

      await _apiEndpoints.safeSendRequest(
        request: (dio, headers) => dio.get(
          ApiEndpoints.ACTIVITY,
          queryParameters: {'page': currentPage, 'per_page': 10},
          options: Options(headers: headers),
        ),
        onSuccess: (data) {
          final List<dynamic> raw = data['data'] ?? [];
          allItems.addAll(raw.map((e) => Activity.fromJson(e)));

          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          lastPage = pagination['last_page'] ?? 1;
          currentPage++;
        },
        onError: (error) {
          pageError = true;
          emit(
            state.copyWith(
              transactionsStatus: HistoryStatus.error,
              transactionsError: error,
            ),
          );
        },
      );

      if (pageError) return;
    } while (currentPage <= lastPage);

    emit(
      state.copyWith(
        transactionsStatus: HistoryStatus.loaded,
        transactions: allItems,
      ),
    );
  }

  Future<void> _onFetchActivity(
    FetchActivity event,
    Emitter<HistoryState> emit,
  ) async {
    emit(
      state.copyWith(
        activityStatus: HistoryStatus.loading,
        activity: [],
        activityError: '',
      ),
    );

    final List<Log> allItems = [];
    int currentPage = 1;
    int lastPage = 1;

    do {
      bool pageError = false;

      await _apiEndpoints.safeSendRequest(
        request: (dio, headers) => dio.get(
          ApiEndpoints.LOGS,
          queryParameters: {'page': currentPage, 'per_page': 10},
          options: Options(headers: headers),
        ),
        onSuccess: (data) {
          final List<dynamic> raw = data['data'] ?? [];
          allItems.addAll(raw.map((e) => Log.fromJson(e)));

          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          lastPage = pagination['last_page'] ?? 1;
          currentPage++;
        },
        onError: (error) {
          pageError = true;
          emit(
            state.copyWith(
              activityStatus: HistoryStatus.error,
              activityError: error,
            ),
          );
        },
      );

      if (pageError) return;
    } while (currentPage <= lastPage);

    emit(
      state.copyWith(activityStatus: HistoryStatus.loaded, activity: allItems),
    );
  }
}

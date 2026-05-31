import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/network/api_endpoints.dart';
import 'package:froggy_mobile/features/dashboard/data/models/dashboard_models.dart';
import 'package:dio/dio.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ApiEndpoints _apiEndpoints = ApiEndpoints();

  DashboardBloc() : super(DashboardState()) {
    on<TabChanged>((event, emit) {
      emit(state.copyWith(currentIndex: event.index));
    });

    on<FetchDashboardData>((event, emit) async {
      emit(state.copyWith(status: DashboardStatus.loading));

      await _apiEndpoints.safeSendRequest(
        request: (dio, headers) => dio.get(
          ApiEndpoints.DASHBOARD,
          options: Options(headers: headers),
        ),
        onSuccess: (data) {
          final dashboardData = DashboardData.fromJson(data);
          emit(state.copyWith(
            status: DashboardStatus.loaded,
            data: dashboardData,
          ));
        },
        onError: (error) {
          emit(state.copyWith(
            status: DashboardStatus.error,
            errorMessage: error,
          ));
        },
      );
    });
  }
}

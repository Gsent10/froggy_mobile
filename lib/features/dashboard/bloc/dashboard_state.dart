part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState {
  final int currentIndex;
  final DashboardStatus status;
  final DashboardData? data;
  final String? errorMessage;

  DashboardState({
    this.currentIndex = 0,
    this.status = DashboardStatus.initial,
    this.data,
    this.errorMessage,
  });

  DashboardState copyWith({
    int? currentIndex,
    DashboardStatus? status,
    DashboardData? data,
    String? errorMessage,
  }) {
    return DashboardState(
      currentIndex: currentIndex ?? this.currentIndex,
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

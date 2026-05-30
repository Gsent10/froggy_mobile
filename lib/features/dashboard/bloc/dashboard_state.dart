part of 'dashboard_bloc.dart';

class DashboardState {
  final int currentIndex;

  DashboardState({this.currentIndex = 0});

  DashboardState copyWith({int? currentIndex}) {
    return DashboardState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

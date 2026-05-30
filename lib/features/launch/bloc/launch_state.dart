part of 'launch_bloc.dart';

enum LaunchStatus { initial, toLogin, toRegister }

class LaunchState {
  final LaunchStatus status;

  LaunchState({this.status = LaunchStatus.initial});

  LaunchState copyWith({LaunchStatus? status}) {
    return LaunchState(status: status ?? this.status);
  }
}

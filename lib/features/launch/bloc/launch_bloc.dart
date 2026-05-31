import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:froggy_mobile/core/utils/user_simple_preferences.dart';

part 'launch_event.dart';
part 'launch_state.dart';

class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  LaunchBloc() : super(LaunchState()) {
    on<CheckLaunchStatus>((event, emit) async {
      final bool? isLaunched = UserSimplePreferences.getLaunched();

      if (isLaunched == true) {
        emit(state.copyWith(status: LaunchStatus.toLogin));
      } else {
        // If not launched before, set launched to true and go to register
        await UserSimplePreferences.setLaunched(true);
        emit(state.copyWith(status: LaunchStatus.toRegister));
      }
    });
  }
}

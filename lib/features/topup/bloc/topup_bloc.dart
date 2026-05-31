import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'topup_event.dart';
part 'topup_state.dart';

class TopupBloc extends Bloc<TopupEvent, TopupState> {
  TopupBloc() : super(TopupInitial()) {
    on<TopupEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

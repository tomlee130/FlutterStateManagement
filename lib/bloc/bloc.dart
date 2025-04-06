import 'package:bloc/bloc.dart';

import 'event.dart';
import 'state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState().init()) {
    on<InitEvent>((event, emit) async {
      emit(await init());
    });

    on<IncrementEvent>((event, emit) {
      emit(state.copyWith(count: state.count + 1));
    });

    on<DecrementEvent>((event, emit) {
      if (state.count > 0) {
        emit(state.copyWith(count: state.count - 1));
      }
    });
  }

  Future<CounterState> init() async {
    return CounterState().clone();
  }
}

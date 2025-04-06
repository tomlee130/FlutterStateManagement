class CounterState {
  final int count;

  CounterState({this.count = 0});

  CounterState init() {
    return CounterState(count: 0);
  }

  CounterState clone() {
    return CounterState(count: count);
  }

  CounterState copyWith({int? count}) {
    return CounterState(
      count: count ?? this.count,
    );
  }
}

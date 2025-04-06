import 'dart:async';

class CounterStream {
  // 创建一个流控制器，用于管理int类型的数据流
  final _counterController = StreamController<int>.broadcast();

  // 当前计数
  int _count = 0;

  // 公开的Stream，供外部监听
  Stream<int> get stream => _counterController.stream;

  // 获取当前计数
  int get count => _count;

  // 增加计数并发送到流
  void increment() {
    _count++;
    _counterController.sink.add(_count);
  }

  // 减少计数并发送到流
  void decrement() {
    if (_count > 0) {
      _count--;
      _counterController.sink.add(_count);
    }
  }

  // 重置计数并发送到流
  void reset() {
    _count = 0;
    _counterController.sink.add(_count);
  }

  // 释放资源
  void dispose() {
    _counterController.close();
  }
}

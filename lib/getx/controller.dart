import 'package:get/get.dart';

class CounterController extends GetxController {
  // 使用RxInt创建可观察的计数状态
  final count = 0.obs;

  // 增加计数
  void increment() {
    count.value++;
  }

  // 减少计数
  void decrement() {
    if (count.value > 0) {
      count.value--;
    }
  }

  // 重置计数
  void reset() {
    count.value = 0;
  }
}

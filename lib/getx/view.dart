import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class GetXCounterPage extends StatelessWidget {
  const GetXCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 实例化并注入控制器，生命周期与页面绑定
    final controller = Get.put(CounterController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.reset,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '当前计数:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            // 使用Obx自动监听状态变化并重建UI
            Obx(
              () => Text(
                '${controller.count.value}',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: controller.decrement,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: controller.increment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

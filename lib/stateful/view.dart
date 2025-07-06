import 'package:flutter/material.dart';
import 'counter_state.dart';

class StatefulCounterPage extends StatefulWidget {
  const StatefulCounterPage({super.key});

  @override
  State<StatefulCounterPage> createState() => _StatefulCounterPageState();
}

class _StatefulCounterPageState extends State<StatefulCounterPage> {
  // 使用CounterState来管理状态
  CounterState _state = const CounterState();

  // 增加计数
  void _increment() {
    setState(() {
      _state = _state.copyWith(count: _state.count + 1);
    });
  }

  // 减少计数
  void _decrement() {
    if (_state.count > 0) {
      setState(() {
        _state = _state.copyWith(count: _state.count - 1);
      });
    }
  }

  // 重置计数
  void _reset() {
    setState(() {
      _state = const CounterState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StatefulWidget'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
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
            Text(
              '${_state.count}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _decrement,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: _increment,
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

import 'package:flutter/services.dart';

class CodeRepository {
  static Future<String> getSourceCode(String filePath) async {
    try {
      // 先尝试从assets加载
      return await rootBundle.loadString(filePath);
    } catch (e) {
      // 如果assets加载失败，从硬编码获取
      return _getHardcodedSource(filePath);
    }
  }

  static String _getHardcodedSource(String filePath) {
    switch (filePath) {
      case 'README.md':
        return '''
# Flutter 状态管理示例

本项目展示了Flutter中五种不同的状态管理实现方式，每种实现都创建了相同功能的计数器应用，以便于比较它们的异同。

## 项目结构

项目包含五个不同的状态管理实现：

- **Bloc**：使用BLoC模式实现的计数器
- **Provider**：使用Provider包实现的计数器  
- **Stream**：使用原生Dart Stream实现的计数器
- **StatefulWidget**：使用Flutter内置StatefulWidget实现的计数器
- **GetX**：使用GetX包实现的计数器

每个实现都在独立的目录中，拥有相似的代码结构和功能。

## 功能

所有计数器实现具有相同的功能：

- 显示当前计数值
- 增加计数按钮
- 减少计数按钮（不允许小于0）
- 重置计数按钮

此外，应用还提供了**源代码浏览器**功能，允许用户在运行时直接查看所有实现的源代码：

- 按类别组织的源代码文件结构
- 带有语法高亮的代码查看器
- 支持明暗两种主题切换
- 代码复制功能
- 适配多种编程语言的语法高亮
''';

      case 'VERSION.MD':
        return '''
# 版本更新记录

## 版本 1.0.0 (2023-04-05)

### 核心功能

#### 五种状态管理实现

1. **Bloc 实现**
   - 使用bloc和flutter_bloc包实现
   - 事件驱动型状态管理
   - 支持初始化、增加和减少计数事件
   - 状态不可变性设计

2. **Provider 实现**
   - 使用provider包实现
   - 轻量级状态管理解决方案
   - 基于ChangeNotifier实现
   - 更新通知机制

3. **Stream 实现**
   - 使用Dart原生Stream和StreamController
   - 完全自定义的状态流实现
   - 支持广播模式
   - 手动管理生命周期和资源释放

4. **StatefulWidget 实现**
   - 使用Flutter内置状态管理
   - setState触发UI更新
   - 封装状态模型
   - 无需第三方库

5. **GetX 实现**
   - 使用GetX包实现
   - 响应式变量（.obs）
   - 简洁的控制器模式
   - 自动状态同步
''';

      case 'lib/bloc/event.dart':
        return '''
abstract class CounterEvent {}

class InitEvent extends CounterEvent {}

class IncrementEvent extends CounterEvent {}

class DecrementEvent extends CounterEvent {}
''';

      case 'lib/bloc/state.dart':
        return '''
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
''';

      case 'lib/bloc/bloc.dart':
        return '''
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
''';

      case 'lib/provider/provider.dart':
        return '''
import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
  
  void decrement() {
    if (_count > 0) {
      _count--;
      notifyListeners();
    }
  }
  
  void reset() {
    _count = 0;
    notifyListeners();
  }
}
''';

      case 'lib/stream/counter_stream.dart':
        return '''
import 'dart:async';

class CounterStream {
  final _counterController = StreamController<int>.broadcast();
  
  int _count = 0;
  
  Stream<int> get stream => _counterController.stream;
  
  int get count => _count;
  
  void increment() {
    _count++;
    _counterController.sink.add(_count);
  }
  
  void decrement() {
    if (_count > 0) {
      _count--;
      _counterController.sink.add(_count);
    }
  }
  
  void reset() {
    _count = 0;
    _counterController.sink.add(_count);
  }
  
  void dispose() {
    _counterController.close();
  }
}
''';

      case 'lib/stateful/counter_state.dart':
        return '''
class CounterState {
  final int count;

  const CounterState({this.count = 0});

  CounterState copyWith({int? count}) {
    return CounterState(
      count: count ?? this.count,
    );
  }
}
''';

      case 'lib/getx/controller.dart':
        return '''
import 'package:get/get.dart';

class CounterController extends GetxController {
  final count = 0.obs;
  
  void increment() {
    count.value++;
  }
  
  void decrement() {
    if (count.value > 0) {
      count.value--;
    }
  }
  
  void reset() {
    count.value = 0;
  }
}
''';

      default:
        return '// 无法找到 $filePath 的源代码';
    }
  }
}

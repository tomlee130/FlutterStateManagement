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

## 依赖

- [bloc](https://pub.dev/packages/bloc): ^8.1.1
- [flutter_bloc](https://pub.dev/packages/flutter_bloc): ^8.1.1
- [provider](https://pub.dev/packages/provider): ^6.1.1
- [get](https://pub.dev/packages/get): ^4.6.6
- [flutter_highlight](https://pub.dev/packages/flutter_highlight): ^0.7.0
- [highlight](https://pub.dev/packages/highlight): ^0.7.0
- [flutter_markdown](https://pub.dev/packages/flutter_markdown): ^0.6.18

## 资源

### 官方文档

- [Flutter 官方文档](https://flutter.dev/docs)
- [Dart 官方文档](https://dart.dev/guides)

### 状态管理相关

- [Flutter Bloc 文档](https://bloclibrary.dev/)
- [Provider 文档](https://pub.dev/documentation/provider/latest/)
- [GetX 文档](https://pub.dev/documentation/get/latest/)
- [Flutter 官方状态管理指南](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)

### 教程与文章

- [Flutter 状态管理终极指南](https://blog.logrocket.com/ultimate-guide-state-management-flutter/)
- [Flutter 中的响应式编程 (RxDart)](https://medium.com/flutter-community/reactive-programming-streams-bloc-6f0d2bd2d248)
- [Flutter 中的 MVVM 模式](https://medium.com/flutterdevs/mvvm-in-flutter-edd212fd767a)

### 视频资源

- [Flutter 中的 Bloc 模式](https://www.youtube.com/watch?v=oxj0RzcNp-Y)
- [Flutter 使用 Provider 进行状态管理](https://www.youtube.com/watch?v=pngZRJFPz3s)
- [Flutter 中的 GetX 状态管理](https://www.youtube.com/watch?v=wtHBdsF4rjU)
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

### 共享功能

每种实现都提供以下功能：
- 显示当前计数值
- 增加计数按钮
- 减少计数按钮（不允许值小于0）
- 重置计数按钮
- 一致的UI设计和用户体验

### 导航与路由

- 统一的主页面选择器
- 使用命名路由系统
- 每个实现均可独立访问
- 支持返回主页面

### 源代码浏览功能

- **文件浏览器**
  - 按实现类别分组展示源代码文件
  - 树状结构展开/折叠
  - 文件描述和路径信息

- **代码查看器**
  - 语法高亮显示（使用flutter_highlight）
  - 支持Dart、Java、JavaScript等多种语言
  - 明暗两种主题切换
  - 代码复制功能
  - 滚动和选择功能

- **资源管理**
  - 源代码文件作为assets加载
  - 硬编码备份机制
  - 自动识别文件类型
  - 支持查看Markdown格式的README和版本历史文档，标准Markdown渲染

### 用户界面

- Material Design 3设计风格
- 响应式布局适配不同屏幕尺寸
- 主题定制和切换
- 统一的视觉风格

### 文档

- 详细的README.md文档
- 各种状态管理方式比较
- 源代码预览
- 环境和依赖说明
- 资源链接集合（官方文档、教程与文章、视频资源）

### 技术规格

- Flutter: 3.22.0
- Dart: 3.4.0
- 依赖包:
  - bloc: ^8.1.1
  - flutter_bloc: ^8.1.1
  - provider: ^6.1.1
  - get: ^4.6.6
  - flutter_highlight: ^0.7.0
  - highlight: ^0.7.0
  - flutter_markdown: ^0.6.18

### 已知问题

- 在某些较低版本的Flutter环境可能存在兼容性问题
- Assets加载在web平台可能需要额外配置

### 后续规划

- 添加更多状态管理实现方式
- 添加单元测试和集成测试
- 性能基准测试比较
- 更复杂的示例应用场景
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

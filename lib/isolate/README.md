# Isolate 多线程状态管理

这是一个使用 Dart Isolate 实现的多线程状态管理示例。

## 特性

- ✅ 真正的多线程并行处理
- ✅ 内存隔离，避免竞态条件
- ✅ 通过 SendPort 进行线程间通信
- ✅ 完整的状态管理生命周期
- ✅ 错误隔离，提高应用稳定性

## 架构组件

### 1. IsolateManager
负责创建和管理 Isolate 实例，处理主线程和 Isolate 之间的通信。

### 2. CounterMessages
定义了命令和状态消息的数据结构：
- `CounterCommand`: 抽象命令基类
- `InitializeCommand`: 初始化命令
- `IncrementCommand`: 增加计数命令
- `DecrementCommand`: 减少计数命令
- `ResetCommand`: 重置计数命令
- `CounterState`: 计数器状态，包含计数值和最后更新时间

### 3. CounterIsolate
在独立线程中运行的计数器逻辑：
- `counterIsolateEntryPoint`: Isolate 入口点函数
- `CounterIsolateController`: 控制器，封装业务逻辑

### 4. View
用户界面，包含三个标签页：
- 计数器操作界面
- 架构介绍文档
- 与其他框架的比较

## 使用方式

```dart
// 创建控制器
final controller = CounterIsolateController(IsolateManager());

// 初始化
await controller.initialize();

// 监听状态变化
controller.stateStream.listen((state) {
  print('计数器值: ${state.count}');
});

// 操作计数器
controller.increment();
controller.decrement();
controller.reset();

// 清理资源
await controller.dispose();
```

## 性能优势

1. **并行处理**: 计数器逻辑在独立线程中运行，不会阻塞 UI
2. **内存隔离**: 每个 Isolate 有独立的内存空间，避免内存竞争
3. **错误隔离**: Isolate 中的错误不会影响主线程
4. **可扩展性**: 可以轻松创建多个 Isolate 处理不同任务

## 适用场景

- 计算密集型任务
- 需要真正并行处理的场景
- 对性能要求极高的应用
- 需要错误隔离的关键任务

## 注意事项

1. **内存开销**: 每个 Isolate 都有独立的内存空间
2. **通信成本**: 消息传递需要序列化/反序列化
3. **调试复杂**: 跨 Isolate 的调试比较困难
4. **资源管理**: 需要正确管理 Isolate 的生命周期 
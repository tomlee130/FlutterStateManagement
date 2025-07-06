import 'dart:isolate';
import 'dart:async';
import 'counter_messages.dart';
import 'isolate_manager.dart';

/// 计数器 Isolate 的入口点函数
///
/// 这个函数在独立的 Isolate 中运行，实现了以下功能：
/// 1. 建立与主线程的双向通信通道
/// 2. 维护计数器的状态
/// 3. 处理来自主线程的命令
/// 4. 将状态变化通知主线程
///
/// 设计原则：
/// - 状态封装：计数器状态完全封装在 Isolate 内部
/// - 命令模式：使用命令对象来封装操作
/// - 不可变性：状态对象是不可变的，每次更新都创建新实例
/// - 错误隔离：Isolate 内的错误不会影响主线程
///
/// [mainSendPort] 主线程提供的发送端口，用于向主线程发送消息
void counterIsolateEntryPoint(SendPort mainSendPort) {
  // 创建接收端口，用于接收来自主线程的消息
  final receivePort = ReceivePort();

  // 第一步：向主线程发送 SendPort（握手协议）
  // 这是 Isolate 通信的标准模式
  mainSendPort.send(receivePort.sendPort);

  // 初始化计数器状态
  // 使用不可变对象确保状态的一致性
  var currentState = CounterState(
    count: 0,
    lastUpdated: DateTime.now(),
  );

  // 立即发送初始状态到主线程
  // 这确保了主线程能够立即获得当前状态
  mainSendPort.send(currentState);

  // 监听来自主线程的命令
  receivePort.listen((message) {
    try {
      // 只处理 CounterCommand 类型的消息
      if (message is CounterCommand) {
        // 处理命令并获取新状态
        final newState = _processCounterCommand(message, currentState);

        // 如果状态发生了变化，更新并通知主线程
        if (newState != currentState) {
          currentState = newState;
          mainSendPort.send(currentState);
        }
      } else {
        // 记录意外的消息类型（在生产环境中应该使用日志系统）
        print('Isolate 收到非预期消息类型: ${message.runtimeType}');
      }
    } catch (error, stackTrace) {
      // Isolate 内的错误处理
      // 发送错误信息到主线程，但不让 Isolate 崩溃
      mainSendPort.send(CounterError(
        message: '处理命令时发生错误: $error',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  });
}

/// 处理计数器命令的纯函数
///
/// 这个函数实现了计数器的核心业务逻辑：
/// - 它是一个纯函数，没有副作用
/// - 输入相同的参数总是返回相同的结果
/// - 不修改输入参数，而是返回新的状态对象
///
/// 这样的设计有以下优势：
/// 1. 易于测试：可以独立测试每个命令的处理逻辑
/// 2. 易于理解：逻辑清晰，没有隐藏的状态变化
/// 3. 线程安全：纯函数天然线程安全
/// 4. 易于调试：状态变化是可预测的
///
/// [command] 要处理的命令
/// [currentState] 当前的计数器状态
///
/// 返回新的计数器状态
CounterState _processCounterCommand(
  CounterCommand command,
  CounterState currentState,
) {
  final now = DateTime.now();

  // 使用模式匹配来处理不同类型的命令
  // 这比传统的 if-else 或 switch 语句更清晰
  return switch (command) {
    InitializeCommand() => CounterState(
        count: 0,
        lastUpdated: now,
      ),
    IncrementCommand() => currentState.copyWith(
        count: currentState.count + 1,
        lastUpdated: now,
      ),
    DecrementCommand() => currentState.copyWith(
        count: currentState.count > 0 ? currentState.count - 1 : 0,
        lastUpdated: now,
      ),
    ResetCommand() => CounterState(
        count: 0,
        lastUpdated: now,
      ),

    // 处理未知命令类型
    // 这确保了即使添加新的命令类型，旧的 Isolate 也不会崩溃
    _ => currentState,
  };
}

/// 计数器 Isolate 的控制器
///
/// 这个类为开发者提供了一个清晰、易用的 API 来与计数器 Isolate 交互。
/// 它隐藏了复杂的 Isolate 通信细节，让开发者可以专注于业务逻辑。
///
/// 设计特点：
/// 1. 职责单一：只负责计数器相关的操作
/// 2. 接口简洁：提供直观的方法名和参数
/// 3. 错误处理：提供清晰的错误信息和恢复机制
/// 4. 资源管理：自动管理 Isolate 的生命周期
///
/// 使用示例：
/// ```dart
/// final controller = CounterIsolateController();
/// await controller.initialize();
///
/// controller.stateStream.listen((state) {
///   print('当前计数: ${state.count}');
/// });
///
/// controller.increment();
/// controller.decrement();
/// controller.reset();
///
/// await controller.dispose();
/// ```
class CounterIsolateController {
  // === 私有成员变量 ===

  /// Isolate 管理器，负责底层的 Isolate 通信
  final IsolateManager<dynamic> _isolateManager;

  /// 状态流控制器，用于向外部提供状态更新
  late final StreamController<CounterState> _stateController;

  /// 错误流控制器，用于向外部提供错误信息
  late final StreamController<CounterError> _errorController;

  /// 当前的计数器状态
  CounterState _currentState = CounterState(
    count: 0,
    lastUpdated: DateTime.now(),
  );

  /// 是否已经初始化
  bool _isInitialized = false;

  /// 是否正在销毁
  bool _isDisposing = false;

  // === 公共 API ===

  /// 当前的计数器状态
  ///
  /// 这个属性提供了对当前状态的同步访问
  /// 即使没有监听状态流，也可以随时获取当前状态
  CounterState get currentState => _currentState;

  /// 计数器状态流
  ///
  /// 监听这个流可以实时获取计数器状态的变化
  /// 流是广播模式，支持多个监听器
  Stream<CounterState> get stateStream => _stateController.stream;

  /// 错误流
  ///
  /// 监听这个流可以获取 Isolate 中发生的错误
  /// 这有助于调试和错误处理
  Stream<CounterError> get errorStream => _errorController.stream;

  /// 检查控制器是否已经准备就绪
  bool get isReady => _isInitialized && !_isDisposing;

  // === 构造函数 ===

  /// 创建一个新的计数器 Isolate 控制器
  ///
  /// [isolateManager] 可选的 Isolate 管理器实例
  /// 如果不提供，会创建一个新的实例
  CounterIsolateController([IsolateManager<dynamic>? isolateManager])
      : _isolateManager = isolateManager ?? IsolateManager<dynamic>() {
    // 初始化流控制器
    _stateController = StreamController<CounterState>.broadcast();
    _errorController = StreamController<CounterError>.broadcast();

    // 设置消息监听器
    _setupMessageListener();
  }

  // === 核心方法 ===

  /// 初始化计数器 Isolate
  ///
  /// 这个方法必须在使用其他方法之前调用
  /// 它会创建 Isolate 并建立通信通道
  ///
  /// 异常处理：
  /// - 如果 Isolate 创建失败，会抛出 IsolateInitializationException
  /// - 如果已经初始化，会直接返回
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (_isDisposing) {
      throw StateError('不能在销毁过程中初始化控制器');
    }

    try {
      await _isolateManager.initialize(counterIsolateEntryPoint);
      _isInitialized = true;

      // 发送初始化命令
      _sendCommand(const InitializeCommand());
    } catch (error) {
      // 初始化失败，确保资源被清理
      await _cleanup();
      rethrow;
    }
  }

  /// 增加计数器的值
  ///
  /// 这个操作会在 Isolate 中执行，不会阻塞主线程
  void increment() {
    _ensureReady();
    _sendCommand(const IncrementCommand());
  }

  /// 减少计数器的值
  ///
  /// 计数器的值不会小于 0
  void decrement() {
    _ensureReady();
    _sendCommand(const DecrementCommand());
  }

  /// 重置计数器为 0
  void reset() {
    _ensureReady();
    _sendCommand(const ResetCommand());
  }

  /// 销毁控制器并清理所有资源
  ///
  /// 这个方法会：
  /// 1. 停止 Isolate
  /// 2. 关闭所有流
  /// 3. 清理内存
  /// 4. 可以安全地多次调用
  Future<void> dispose() async {
    if (_isDisposing) {
      return;
    }

    _isDisposing = true;
    await _cleanup();
  }

  // === 私有辅助方法 ===

  /// 设置消息监听器
  ///
  /// 这个方法处理来自 Isolate 的消息分发
  void _setupMessageListener() {
    _isolateManager.messageStream.listen(
      (message) {
        if (message is CounterState) {
          _handleStateUpdate(message);
        } else if (message is CounterError) {
          _handleError(message);
        }
      },
      onError: (error, stackTrace) {
        // 处理流错误
        _errorController.add(CounterError(
          message: '消息流发生错误: $error',
          originalError: error,
          stackTrace: stackTrace,
        ));
      },
    );
  }

  /// 处理状态更新
  void _handleStateUpdate(CounterState newState) {
    if (_isDisposing) return;

    _currentState = newState;
    _stateController.add(newState);
  }

  /// 处理错误
  void _handleError(CounterError error) {
    if (_isDisposing) return;

    _errorController.add(error);
  }

  /// 向 Isolate 发送命令
  void _sendCommand(CounterCommand command) {
    try {
      _isolateManager.sendMessage(command);
    } catch (error) {
      _errorController.add(CounterError(
        message: '发送命令失败: $error',
        originalError: error,
      ));
    }
  }

  /// 确保控制器已经准备就绪
  void _ensureReady() {
    if (!isReady) {
      throw StateError('控制器尚未准备就绪。'
          '请先调用 initialize() 方法。'
          '当前状态：initialized=$_isInitialized, disposing=$_isDisposing');
    }
  }

  /// 清理所有资源
  Future<void> _cleanup() async {
    _isInitialized = false;

    // 清理 Isolate 管理器
    await _isolateManager.dispose();

    // 关闭流控制器
    await _stateController.close();
    await _errorController.close();
  }
}

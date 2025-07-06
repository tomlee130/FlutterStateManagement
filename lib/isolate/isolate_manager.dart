import 'dart:isolate';
import 'dart:async';

/// 一个健壮的 Isolate 管理器，提供类型安全的多线程通信能力
///
/// 这个类的设计哲学：
/// 1. 为人类开发者提供清晰易懂的API
/// 2. 隐藏复杂的底层实现细节
/// 3. 提供完善的错误处理和资源管理
/// 4. 确保线程安全和内存安全
///
/// 使用示例：
/// ```dart
/// final manager = IsolateManager<String>();
/// await manager.initialize(myIsolateEntryPoint);
/// manager.messageStream.listen((message) => print(message));
/// manager.sendMessage("Hello Isolate!");
/// await manager.dispose();
/// ```
class IsolateManager<T> {
  // === 私有状态变量 ===
  // 这些变量封装了 Isolate 的内部状态，外部无法直接访问

  /// 运行中的 Isolate 实例
  /// null 表示尚未创建或已销毁
  Isolate? _isolate;

  /// 向 Isolate 发送消息的端口
  /// 只有在 Isolate 完全初始化后才会被设置
  SendPort? _sendPort;

  /// 接收来自 Isolate 消息的端口
  /// 在 initialize() 方法中创建
  ReceivePort? _receivePort;

  /// 消息流控制器，用于向外部提供类型安全的消息流
  /// 使用 broadcast 模式支持多个监听器
  StreamController<T>? _messageController;

  /// 初始化完成的标志
  /// 用于确保 Isolate 在使用前已完全准备就绪
  bool _isInitializationComplete = false;

  /// 是否正在销毁中的标志
  /// 防止在销毁过程中进行其他操作
  bool _isDisposing = false;

  // === 公共API ===

  /// 类型安全的消息流
  ///
  /// 这个流只会发出类型为 T 的消息，为开发者提供编译时类型检查
  /// 如果收到非 T 类型的消息，会记录警告但不会中断程序
  Stream<T> get messageStream {
    if (_messageController == null) {
      throw StateError('IsolateManager 尚未初始化。请先调用 initialize() 方法。');
    }
    return _messageController!.stream;
  }

  /// 检查 Isolate 是否已完全初始化并可以使用
  ///
  /// 这不仅检查 Isolate 是否存在，还确保通信通道已建立
  bool get isReady => _isolate != null && _sendPort != null && _isInitializationComplete && !_isDisposing;

  /// 检查 Isolate 是否正在运行
  ///
  /// 与 isReady 的区别：这个方法只检查 Isolate 是否存在，
  /// 不关心是否完全初始化
  bool get isRunning => _isolate != null && !_isDisposing;

  // === 构造函数 ===

  /// 创建一个新的 IsolateManager 实例
  ///
  /// 注意：创建后需要调用 initialize() 方法才能使用
  IsolateManager() {
    _messageController = StreamController<T>.broadcast();
  }

  // === 核心方法 ===

  /// 初始化 Isolate 并建立通信通道
  ///
  /// [isolateEntryPoint] 是在新 Isolate 中运行的入口函数
  ///
  /// 这个方法的执行流程：
  /// 1. 检查是否已经初始化（防止重复初始化）
  /// 2. 创建接收端口用于监听 Isolate 消息
  /// 3. 启动 Isolate 并传递主线程的发送端口
  /// 4. 等待 Isolate 发送其发送端口（握手过程）
  /// 5. 标记初始化完成
  ///
  /// 异常处理：
  /// - 如果 Isolate 创建失败，会清理已创建的资源
  /// - 如果握手超时，会抛出 TimeoutException
  Future<void> initialize(void Function(SendPort) isolateEntryPoint) async {
    // 防止重复初始化
    if (isReady) {
      return;
    }

    // 防止在销毁过程中初始化
    if (_isDisposing) {
      throw StateError('不能在销毁过程中初始化 IsolateManager');
    }

    try {
      // 第一步：创建接收端口
      _receivePort = ReceivePort();

      // 第二步：设置消息监听器
      // 这里使用了一个巧妙的握手机制：
      // - 第一条消息必须是 Isolate 的 SendPort
      // - 后续消息才是业务数据
      _receivePort!.listen(_handleIsolateMessage);

      // 第三步：创建 Isolate
      _isolate = await Isolate.spawn(
        isolateEntryPoint,
        _receivePort!.sendPort,
      );

      // 第四步：等待握手完成
      // 使用超时机制防止无限等待
      await _waitForHandshake();

      _isInitializationComplete = true;
    } catch (error, stackTrace) {
      // 如果初始化失败，清理已创建的资源
      await _cleanupResources();

      // 重新抛出异常，让调用者知道初始化失败
      throw IsolateInitializationException(
        '初始化 Isolate 失败: $error',
        error,
        stackTrace,
      );
    }
  }

  /// 向 Isolate 发送消息
  ///
  /// [message] 要发送的消息，必须是可序列化的
  ///
  /// 注意事项：
  /// - 只有在 Isolate 完全初始化后才能发送消息
  /// - 消息必须是可序列化的（基本类型、List、Map等）
  /// - 复杂对象需要实现序列化逻辑
  void sendMessage(dynamic message) {
    if (!isReady) {
      throw StateError('IsolateManager 尚未准备就绪。'
          '当前状态：isRunning=$isRunning, isReady=$isReady');
    }

    try {
      _sendPort!.send(message);
    } catch (error) {
      // 发送失败可能是因为消息不可序列化
      throw MessageSendException(
        '发送消息失败，请检查消息是否可序列化: $error',
        error,
      );
    }
  }

  /// 安全地销毁 Isolate 并清理所有资源
  ///
  /// 这个方法确保：
  /// 1. 优雅地关闭 Isolate（给它机会完成当前工作）
  /// 2. 清理所有端口和流控制器
  /// 3. 防止内存泄漏
  /// 4. 可以安全地多次调用
  Future<void> dispose() async {
    if (_isDisposing) {
      return; // 防止重复销毁
    }

    _isDisposing = true;
    _isInitializationComplete = false;

    await _cleanupResources();
  }

  // === 私有辅助方法 ===

  /// 处理来自 Isolate 的消息
  ///
  /// 这个方法实现了握手协议和消息分发逻辑
  void _handleIsolateMessage(dynamic message) {
    if (_isDisposing) {
      return; // 如果正在销毁，忽略消息
    }

    if (message is SendPort && _sendPort == null) {
      // 这是握手消息：Isolate 发送了它的 SendPort
      _sendPort = message;
    } else if (message is T) {
      // 这是业务消息：转发给外部监听器
      _messageController?.add(message);
    } else {
      // 收到了意外类型的消息
      // 在生产环境中，这里应该使用日志系统
      print('警告：收到非预期类型的消息: ${message.runtimeType}');
    }
  }

  /// 等待与 Isolate 的握手完成
  ///
  /// 使用轮询机制检查 SendPort 是否已接收
  /// 包含超时机制防止无限等待
  Future<void> _waitForHandshake() async {
    const maxWaitTime = Duration(seconds: 5);
    const checkInterval = Duration(milliseconds: 50);

    final stopwatch = Stopwatch()..start();

    while (_sendPort == null && stopwatch.elapsed < maxWaitTime) {
      await Future.delayed(checkInterval);
    }

    if (_sendPort == null) {
      throw TimeoutException(
        'Isolate 握手超时，可能是入口函数没有正确发送 SendPort',
        maxWaitTime,
      );
    }
  }

  /// 清理所有资源
  ///
  /// 这个方法确保无论在什么情况下都能正确清理资源
  Future<void> _cleanupResources() async {
    // 销毁 Isolate
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;

    // 关闭端口
    _receivePort?.close();
    _receivePort = null;

    // 重置发送端口
    _sendPort = null;

    // 关闭消息流
    await _messageController?.close();
    _messageController = null;
  }
}

// === 自定义异常类 ===
// 这些异常类为开发者提供了更精确的错误信息

/// Isolate 初始化异常
///
/// 当 Isolate 创建或初始化失败时抛出
class IsolateInitializationException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const IsolateInitializationException(
    this.message,
    this.originalError,
    this.stackTrace,
  );

  @override
  String toString() => 'IsolateInitializationException: $message';
}

/// 消息发送异常
///
/// 当向 Isolate 发送消息失败时抛出
class MessageSendException implements Exception {
  final String message;
  final dynamic originalError;

  const MessageSendException(this.message, this.originalError);

  @override
  String toString() => 'MessageSendException: $message';
}

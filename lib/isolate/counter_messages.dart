// 计数器 Isolate 的消息定义
//
// 这个文件定义了主线程和 Isolate 之间通信的所有消息类型。
// 设计原则：
// 1. 类型安全：每种消息都有明确的类型
// 2. 不可变性：所有消息对象都是不可变的
// 3. 可序列化：所有消息都可以在 Isolate 之间传递
// 4. 清晰的语义：每个消息类型都有明确的含义和用途

// === 命令消息 ===
// 这些消息从主线程发送到 Isolate，用于请求特定的操作

/// 计数器命令的基类
///
/// 使用抽象基类确保类型安全，所有具体的命令都必须继承这个类
/// 这样可以在编译时检查命令类型的正确性
abstract class CounterCommand {
  /// 创建一个计数器命令
  ///
  /// 使用 const 构造函数确保命令对象是不可变的
  const CounterCommand();
}

/// 初始化命令
///
/// 这个命令用于将计数器重置为初始状态
/// 通常在 Isolate 启动时或需要重新开始时使用
class InitializeCommand extends CounterCommand {
  /// 创建一个初始化命令
  const InitializeCommand();

  @override
  String toString() => 'InitializeCommand()';

  @override
  bool operator ==(Object other) => other is InitializeCommand;

  @override
  int get hashCode => 0;
}

/// 增加计数命令
///
/// 这个命令用于将计数器的值增加 1
class IncrementCommand extends CounterCommand {
  /// 创建一个增加计数命令
  const IncrementCommand();

  @override
  String toString() => 'IncrementCommand()';

  @override
  bool operator ==(Object other) => other is IncrementCommand;

  @override
  int get hashCode => 1;
}

/// 减少计数命令
///
/// 这个命令用于将计数器的值减少 1
/// 如果当前值为 0，则保持不变
class DecrementCommand extends CounterCommand {
  /// 创建一个减少计数命令
  const DecrementCommand();

  @override
  String toString() => 'DecrementCommand()';

  @override
  bool operator ==(Object other) => other is DecrementCommand;

  @override
  int get hashCode => 2;
}

/// 重置计数命令
///
/// 这个命令用于将计数器重置为 0
class ResetCommand extends CounterCommand {
  /// 创建一个重置计数命令
  const ResetCommand();

  @override
  String toString() => 'ResetCommand()';

  @override
  bool operator ==(Object other) => other is ResetCommand;

  @override
  int get hashCode => 3;
}

// === 状态消息 ===
// 这些消息从 Isolate 发送到主线程，用于报告状态变化

/// 计数器状态
///
/// 这个类表示计数器的当前状态，包含计数值和最后更新时间
/// 设计为不可变对象，确保状态的一致性和线程安全
class CounterState {
  /// 当前的计数值
  ///
  /// 这个值始终大于等于 0
  final int count;

  /// 最后更新时间
  ///
  /// 记录状态最后一次变化的时间，用于调试和监控
  final DateTime lastUpdated;

  /// 创建一个计数器状态
  ///
  /// [count] 计数值，必须大于等于 0
  /// [lastUpdated] 最后更新时间
  const CounterState({
    required this.count,
    required this.lastUpdated,
  }) : assert(count >= 0, '计数值不能为负数');

  /// 创建一个状态的副本，可以修改部分属性
  ///
  /// 这个方法实现了函数式编程中的"copy with"模式
  /// 允许创建新的状态对象而不修改原对象
  ///
  /// [count] 新的计数值
  /// [lastUpdated] 新的最后更新时间
  CounterState copyWith({
    int? count,
    DateTime? lastUpdated,
  }) {
    return CounterState(
      count: count ?? this.count,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() => 'CounterState(count: $count, lastUpdated: $lastUpdated)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CounterState && other.count == count && other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => count.hashCode ^ lastUpdated.hashCode;
}

// === 错误消息 ===
// 这些消息用于报告 Isolate 中发生的错误

/// 计数器错误
///
/// 这个类表示在 Isolate 中发生的错误
/// 提供了详细的错误信息，有助于调试和错误处理
class CounterError {
  /// 错误消息
  ///
  /// 人类可读的错误描述
  final String message;

  /// 原始错误对象
  ///
  /// 导致这个错误的原始异常或错误对象
  final dynamic originalError;

  /// 堆栈跟踪
  ///
  /// 错误发生时的堆栈跟踪信息，用于调试
  final StackTrace? stackTrace;

  /// 错误发生时间
  ///
  /// 记录错误发生的时间，用于日志和监控
  final DateTime timestamp;

  /// 创建一个计数器错误
  ///
  /// [message] 错误消息
  /// [originalError] 原始错误对象
  /// [stackTrace] 堆栈跟踪信息
  /// [timestamp] 错误发生时间，默认为当前时间
  CounterError({
    required this.message,
    this.originalError,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    final buffer = StringBuffer('CounterError: $message');

    if (originalError != null) {
      buffer.write('\n原始错误: $originalError');
    }

    if (stackTrace != null) {
      buffer.write('\n堆栈跟踪:\n$stackTrace');
    }

    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CounterError &&
        other.message == message &&
        other.originalError == originalError &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => message.hashCode ^ originalError.hashCode ^ timestamp.hashCode;
}

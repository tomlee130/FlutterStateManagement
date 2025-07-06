import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'counter_isolate.dart';
import 'counter_messages.dart';

/// Isolate 计数器页面的主组件
///
/// 这个页面展示了如何使用 Isolate 进行多线程状态管理。
/// 它包含三个主要部分：
/// 1. 计数器操作界面 - 展示实际的计数器功能
/// 2. 架构介绍 - 详细解释 Isolate 的工作原理
/// 3. 框架比较 - 与其他状态管理方案的对比
///
/// 设计特点：
/// - 清晰的职责分离：每个标签页负责不同的功能
/// - 完善的错误处理：显示错误信息并提供恢复机制
/// - 响应式设计：适应不同的屏幕尺寸
/// - 用户友好的界面：直观的操作和清晰的反馈
class IsolateCounterPage extends StatefulWidget {
  /// 创建一个 Isolate 计数器页面
  const IsolateCounterPage({super.key});

  @override
  State<IsolateCounterPage> createState() => _IsolateCounterPageState();
}

/// Isolate 计数器页面的状态管理
///
/// 这个类负责：
/// 1. 管理 CounterIsolateController 的生命周期
/// 2. 处理用户界面状态
/// 3. 显示错误信息和加载状态
/// 4. 确保资源的正确清理
class _IsolateCounterPageState extends State<IsolateCounterPage> {
  // === 私有状态变量 ===

  /// 计数器 Isolate 控制器
  ///
  /// 这个控制器封装了与 Isolate 的所有交互
  /// 包括初始化、状态管理、错误处理等
  late CounterIsolateController _controller;

  /// 初始化状态标志
  ///
  /// 用于控制 UI 的显示状态，确保在 Isolate 准备就绪前显示加载指示器
  bool _isInitialized = false;

  /// 错误状态
  ///
  /// 如果初始化或运行过程中发生错误，这里会保存错误信息
  CounterError? _lastError;

  /// 是否正在初始化
  ///
  /// 用于显示初始化进度，防止用户重复操作
  bool _isInitializing = false;

  // === 生命周期方法 ===

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    // 确保在页面销毁时清理所有资源
    // 这防止了内存泄漏和后台进程的残留
    _controller.dispose();
    super.dispose();
  }

  // === 初始化方法 ===

  /// 初始化计数器控制器
  ///
  /// 这个方法负责：
  /// 1. 创建控制器实例
  /// 2. 设置错误监听器
  /// 3. 初始化 Isolate
  /// 4. 处理初始化过程中的错误
  Future<void> _initializeController() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
      _lastError = null;
    });

    try {
      // 创建控制器实例
      _controller = CounterIsolateController();

      // 设置错误监听器
      _controller.errorStream.listen(_handleError);

      // 初始化 Isolate
      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isInitializing = false;
        });
      }
    } catch (error, stackTrace) {
      if (mounted) {
        setState(() {
          _lastError = CounterError(
            message: '初始化失败: $error',
            originalError: error,
            stackTrace: stackTrace,
          );
          _isInitializing = false;
        });
      }
    }
  }

  /// 处理错误
  ///
  /// 当 Isolate 中发生错误时，这个方法会被调用
  /// 它会更新 UI 状态并显示错误信息
  void _handleError(CounterError error) {
    if (mounted) {
      setState(() {
        _lastError = error;
      });

      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('发生错误: ${error.message}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: '重试',
            textColor: Colors.white,
            onPressed: _retryInitialization,
          ),
        ),
      );
    }
  }

  /// 重试初始化
  ///
  /// 当发生错误时，用户可以点击重试按钮重新初始化
  void _retryInitialization() {
    _initializeController();
  }

  // === UI 构建方法 ===

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: TabBarView(
          children: [
            _buildCounterTab(),
            // _buildArchitectureTab(),
            // _buildComparisonTab(),
          ],
        ),
      ),
    );
  }

  /// 构建应用栏
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Isolate 多线程计数器'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: '返回',
      ),
      bottom: const TabBar(
        tabs: [
          Tab(
            icon: Icon(Icons.calculate),
            text: '计数器',
          ),
          Tab(
            icon: Icon(Icons.architecture),
            text: '架构介绍',
          ),
          Tab(
            icon: Icon(Icons.compare),
            text: '框架比较',
          ),
        ],
      ),
      actions: [
        // 重试按钮 - 当发生错误时显示
        if (_lastError != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _retryInitialization,
            tooltip: '重新初始化',
          ),
      ],
    );
  }

  /// 构建计数器标签页
  Widget _buildCounterTab() {
    // 显示错误状态
    if (_lastError != null) {
      return _buildErrorWidget();
    }

    // 显示加载状态
    if (_isInitializing || !_isInitialized) {
      return _buildLoadingWidget();
    }

    // 显示计数器界面
    return _buildCounterInterface();
  }

  /// 构建错误显示组件
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '初始化失败',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _lastError?.message ?? '未知错误',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retryInitialization,
              icon: const Icon(Icons.refresh),
              label: const Text('重新初始化'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建加载显示组件
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _isInitializing ? '正在初始化 Isolate...' : '准备中...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (_isInitializing) ...[
            const SizedBox(height: 8),
            const Text(
              '这可能需要几秒钟时间',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建计数器界面
  Widget _buildCounterInterface() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 计数器显示区域
          _buildCounterDisplay(),

          const SizedBox(height: 32),

          // 操作按钮区域
          _buildActionButtons(),

          const SizedBox(height: 32),

          // 说明卡片
          _buildInfoCard(),
        ],
      ),
    );
  }

  /// 构建计数器显示区域
  Widget _buildCounterDisplay() {
    return Column(
      children: [
        const Text(
          '当前计数:',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        StreamBuilder<CounterState>(
          stream: _controller.stateStream,
          initialData: _controller.currentState,
          builder: (context, snapshot) {
            final state = snapshot.data ?? _controller.currentState;
            return Column(
              children: [
                Text(
                  '${state.count}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '最后更新: ${_formatDateTime(state.lastUpdated)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// 构建操作按钮区域
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.remove,
          onPressed: _controller.decrement,
          tooltip: '减少计数',
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.refresh,
          onPressed: _controller.reset,
          tooltip: '重置计数',
          isText: true,
          text: '重置',
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.add,
          onPressed: _controller.increment,
          tooltip: '增加计数',
        ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isText = false,
    String? text,
  }) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: isText ? const EdgeInsets.symmetric(horizontal: 20, vertical: 16) : const EdgeInsets.all(16),
        ),
        child: isText ? Text(text!) : Icon(icon),
      ),
    );
  }

  /// 构建信息卡片
  Widget _buildInfoCard() {
    return const Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '多线程状态说明',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• 计数器逻辑运行在独立的 Isolate 中\n'
              '• UI 线程通过 SendPort 发送命令\n'
              '• Isolate 通过 SendPort 回传状态更新\n'
              '• 真正的多线程并行处理，不会阻塞 UI\n'
              '• 错误隔离：Isolate 中的错误不会影响主线程',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
//
//   /// 构建架构介绍标签页
//   Widget _buildArchitectureTab() {
//     return const SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Markdown(
//         selectable: true,
//         data: '''
// # Isolate 多线程架构
//
// ## 什么是 Isolate？
//
// Isolate 是 Dart 的并发模型，提供真正的多线程能力。Isolate 之间不共享内存，通过消息传递通信。
//
// ### 核心特点
//
// - **内存隔离**：每个 Isolate 有独立内存空间
// - **消息传递**：使用 SendPort 和 ReceivePort 通信
// - **真正并行**：在多核设备上并行执行
//
// ## 架构设计
//
// ```
// ┌─────────────────┐    SendPort     ┌─────────────────┐
// │   UI Thread     │ ──────────────→ │   Counter       │
// │                 │                 │   Isolate       │
// │ - View          │ ←────────────── │                 │
// │ - Controller    │    SendPort     │ - Logic         │
// │ - IsolateManager│                 │ - State         │
// └─────────────────┘                 └─────────────────┘
// ```
//
// ### 组件职责
//
// 1. **IsolateManager**: 管理 Isolate 生命周期和通信
// 2. **CounterIsolateController**: 封装业务逻辑，提供 API
// 3. **CounterMessages**: 定义命令和状态消息
// 4. **CounterIsolate**: 在独立线程中运行计数器逻辑
//
// ### 通信流程
//
// 1. **握手**：Isolate 启动后发送 SendPort 给主线程
// 2. **命令**：主线程发送 CounterCommand 到 Isolate
// 3. **响应**：Isolate 处理命令后发送 CounterState 回主线程
// 4. **错误**：发生错误时发送 CounterError 对象
//
// ## 设计模式
//
// - **命令模式**：使用 CounterCommand 封装操作
// - **状态模式**：CounterState 是不可变对象
// - **观察者模式**：通过 Stream 通知状态变化
//
// ## 优势
//
// - **真正多线程**：在多核设备上并行处理
// - **内存安全**：避免共享内存问题
// - **错误隔离**：Isolate 崩溃不影响主线程
// - **无锁编程**：不需要锁保护共享资源
//
// ## 适用场景
//
// **适合**：计算密集型任务、需要并行处理、长时间运行任务
// **不适合**：简单状态管理、频繁通信、内存敏感应用
// ''',
//       ),
//     );
//   }
//
//   /// 构建框架比较标签页
//   Widget _buildComparisonTab() {
//     return const SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Markdown(
//         selectable: true,
//         data: '''
// # 多线程状态管理框架对比
//
// ## 架构对比
//
// ### 1. Isolate vs StatefulWidget
//
// | 特性 | Isolate | StatefulWidget |
// |------|---------|----------------|
// | 线程模型 | 多线程 | 单线程 |
// | 内存模型 | 隔离 | 共享 |
// | 复杂度 | 高 | 低 |
// | 性能 | 高（并行） | 中（顺序） |
// | 适用场景 | 计算密集型 | 简单状态 |
// | 错误隔离 | 完全隔离 | 无隔离 |
//
// ### 2. Isolate vs BLoC
//
// | 特性 | Isolate | BLoC |
// |------|---------|------|
// | 线程模型 | 多线程 | 单线程 |
// | 事件处理 | 消息传递 | Stream |
// | 状态管理 | 隔离状态 | 响应式状态 |
// | 测试友好性 | 中 | 高 |
// | 学习曲线 | 陡峭 | 中等 |
// | 性能 | 极高 | 高 |
//
// ### 3. Isolate vs Provider
//
// | 特性 | Isolate | Provider |
// |------|---------|----------|
// | 线程模型 | 多线程 | 单线程 |
// | 依赖注入 | 手动管理 | 自动管理 |
// | 状态共享 | 消息传递 | 直接访问 |
// | 性能 | 高（并行） | 中（优化） |
// | 易用性 | 低 | 高 |
//
// ### 4. Isolate vs GetX
//
// | 特性 | Isolate | GetX |
// |------|---------|------|
// | 线程模型 | 多线程 | 单线程 |
// | 响应式 | 手动实现 | 内置支持 |
// | 路由管理 | 无 | 内置 |
// | 包大小 | 小 | 大 |
// | 学习成本 | 高 | 低 |
//
// ### 5. Isolate vs Stream
//
// | 特性 | Isolate | Stream |
// |------|---------|--------|
// | 线程模型 | 多线程 | 单线程 |
// | 异步处理 | 并行 | 顺序 |
// | 错误处理 | 隔离 | 传播 |
// | 资源管理 | 复杂 | 简单 |
//
// ## 性能对比
//
// ### CPU 密集型任务
// ```
// Isolate > Stream > BLoC > Provider > GetX > StatefulWidget
// ```
//
// ### 内存使用
// ```
// StatefulWidget < Provider < GetX < BLoC < Stream < Isolate
// ```
//
// ### 开发效率
// ```
// StatefulWidget < Provider < GetX < Stream < BLoC < Isolate
// ```
//
// ## 选择指南
//
// ### 选择 Isolate 的情况
// - 需要处理计算密集型任务
// - 要求真正的并行处理
// - 对性能有极高要求
// - 需要错误隔离
//
// ### 选择其他方案的情况
// - **StatefulWidget**: 简单的本地状态管理
// - **Provider**: 需要依赖注入和状态共享
// - **BLoC**: 需要严格的架构和测试
// - **GetX**: 需要完整的应用框架
// - **Stream**: 需要响应式编程但不需要多线程
//
// ## 混合使用
//
// 在实际项目中可以混合使用：
//
// - **Isolate + Provider**: Isolate 处理计算任务，Provider 管理全局状态
// - **Isolate + BLoC**: Isolate 处理后台任务，BLoC 管理 UI 状态
// - **Isolate + StatefulWidget**: Isolate 处理复杂计算，StatefulWidget 管理简单状态
// ''',
//       ),
//     );
//   }

  // === 辅助方法 ===

  /// 格式化日期时间
  ///
  /// 将 DateTime 对象格式化为用户友好的字符串
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }
}

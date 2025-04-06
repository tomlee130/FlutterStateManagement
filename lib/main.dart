import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'bloc/view.dart';
import 'getx/view.dart';
import 'provider/view.dart';
import 'stateful/view.dart';
import 'stream/view.dart';
import 'source_viewer/source_list.dart';

// 事件
abstract class CounterEvent {}

class IncrementEvent extends CounterEvent {}

// 状态管理
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<IncrementEvent>((event, emit) => emit(state + 1));
  }
}

// 使用
class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
          return Scaffold(
              body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Text('$count'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.read<CounterBloc>().add(IncrementEvent()),
                      child: const Text('增加'),
                    ),
                  ],
                )
              ]));
        },
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter 状态管理示例',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 注册命名路由
      routes: {
        '/': (context) => const HomePage(),
        '/bloc': (context) => const CounterPage(),
        '/provider': (context) => const ProviderPage(),
        '/stream': (context) => const StreamPage(),
        '/stateful': (context) => const StatefulCounterPage(),
        '/getx': (context) => const GetXCounterPage(),
        '/source_browser': (context) => const SourceCodeBrowser(),
      },
      initialRoute: '/',
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 状态管理示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () => Navigator.pushNamed(context, '/source_browser'),
            tooltip: '查看源代码',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionCard(
              context,
              title: 'Bloc 实现',
              description: '使用 BLoC 模式进行状态管理',
              icon: Icons.architecture,
              route: '/bloc',
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              title: 'Provider 实现',
              description: '使用 Provider 包进行状态管理',
              icon: Icons.data_usage,
              route: '/provider',
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              title: 'Stream 实现',
              description: '使用原生 Stream 进行状态管理',
              icon: Icons.sync_alt,
              route: '/stream',
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              title: 'StatefulWidget 实现',
              description: '使用Flutter内置的StatefulWidget管理状态',
              icon: Icons.widgets,
              route: '/stateful',
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              title: 'GetX 实现',
              description: '使用GetX进行状态管理和依赖注入',
              icon: Icons.catching_pokemon,
              route: '/getx',
            ),
          ],
        ),
        )
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String route,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

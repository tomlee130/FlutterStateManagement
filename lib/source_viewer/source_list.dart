import 'package:flutter/material.dart';
import 'code_viewer.dart';

class SourceCodeBrowser extends StatefulWidget {
  const SourceCodeBrowser({super.key});

  @override
  State<SourceCodeBrowser> createState() => _SourceCodeBrowserState();
}

class _SourceCodeBrowserState extends State<SourceCodeBrowser> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        dividerColor: _isDarkMode ? Colors.white24 : Colors.black12,
        listTileTheme: ListTileThemeData(
          textColor: _isDarkMode ? Colors.white : null,
          iconColor: _isDarkMode ? Colors.white70 : null,
        ),
        expansionTileTheme: ExpansionTileThemeData(
          textColor: _isDarkMode ? Colors.white : null,
          iconColor: _isDarkMode ? Colors.white70 : null,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('源代码浏览器'),
          iconTheme: IconThemeData(
            color: _isDarkMode ? Colors.white : null,
          ),
          backgroundColor: _isDarkMode ? const Color(0xFF2C2C2C) : null,
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
              tooltip: _isDarkMode ? '切换至浅色主题' : '切换至深色主题',
            ),
          ],
        ),
        body: ListView(
          children: [
            _buildCategoryTile(context, '项目文档', [
              _CodeFile('项目说明', 'README.md', 'markdown', Icons.description),
              _CodeFile('版本历史', 'VERSION.MD', 'markdown', Icons.history),
            ]),
            _buildCategoryTile(context, 'Bloc 实现', [
              _CodeFile('事件定义', 'lib/bloc/event.dart', 'dart'),
              _CodeFile('状态定义', 'lib/bloc/state.dart', 'dart'),
              _CodeFile('业务逻辑', 'lib/bloc/bloc.dart', 'dart'),
              _CodeFile('UI视图', 'lib/bloc/view.dart', 'dart'),
            ]),
            _buildCategoryTile(context, 'Provider 实现', [
              _CodeFile('状态提供者', 'lib/provider/provider.dart', 'dart'),
              _CodeFile('UI视图', 'lib/provider/view.dart', 'dart'),
            ]),
            _buildCategoryTile(context, 'Stream 实现', [
              _CodeFile('流控制器', 'lib/stream/counter_stream.dart', 'dart'),
              _CodeFile('UI视图', 'lib/stream/view.dart', 'dart'),
            ]),
            _buildCategoryTile(context, 'StatefulWidget 实现', [
              _CodeFile('状态定义', 'lib/stateful/counter_state.dart', 'dart'),
              _CodeFile('UI视图', 'lib/stateful/view.dart', 'dart'),
            ]),
            _buildCategoryTile(context, 'GetX 实现', [
              _CodeFile('控制器', 'lib/getx/controller.dart', 'dart'),
              _CodeFile('UI视图', 'lib/getx/view.dart', 'dart'),
            ]),
            _buildCategoryTile(context, '应用核心', [
              _CodeFile('主程序', 'lib/main.dart', 'dart'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, String title, List<_CodeFile> files) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _isDarkMode ? Colors.white : null,
        ),
      ),
      children: files
          .map((file) => ListTile(
                leading: Icon(
                  file.icon ?? Icons.code,
                  color: _isDarkMode ? Colors.white70 : null,
                ),
                title: Text(file.title),
                subtitle: Text(
                  file.path,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CodeViewerPage(
                      title: '${file.title} (${file.path})',
                      filePath: file.path,
                      language: file.language,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _CodeFile {
  final String title;
  final String path;
  final String language;
  final IconData? icon;

  _CodeFile(this.title, this.path, this.language, [this.icon]);
}

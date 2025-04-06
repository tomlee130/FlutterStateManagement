import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'code_repository.dart';
import 'syntax_highlighter.dart';
import 'markdown_viewer.dart';

class CodeViewerPage extends StatefulWidget {
  final String title;
  final String filePath;
  final String language;

  const CodeViewerPage({
    super.key,
    required this.title,
    required this.filePath,
    required this.language,
  });

  @override
  State<CodeViewerPage> createState() => _CodeViewerPageState();
}

class _CodeViewerPageState extends State<CodeViewerPage> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
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
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyCode(context),
              tooltip: '复制代码',
            ),
          ],
        ),
        body: FutureBuilder<String>(
          future: CodeRepository.getSourceCode(widget.filePath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '加载失败: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('文件为空'));
            }

            return _buildCodeView(context, snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildCodeView(BuildContext context, String code) {
    final bool isMarkdown = widget.language == 'markdown';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.filePath,
            style: TextStyle(
              color: _isDarkMode ? Colors.grey : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          isMarkdown
              ? MarkdownViewer(
                  markdown: code,
                  isDarkMode: _isDarkMode,
                )
              : SyntaxHighlighterView(
                  code: code,
                  language: widget.language,
                  isDarkMode: _isDarkMode,
                ),
        ],
      ),
    );
  }

  void _copyCode(BuildContext context) async {
    final code = await CodeRepository.getSourceCode(widget.filePath);
    if (code.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: code));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('代码已复制到剪贴板')),
        );
      }
    }
  }
}

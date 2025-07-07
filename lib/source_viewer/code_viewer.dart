import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("zh-CN");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
    
    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('朗读出错: $msg')),
        );
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
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
              icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
              onPressed: _isSpeaking ? _stopSpeaking : _speakCode,
              tooltip: _isSpeaking ? '停止朗读' : '朗读全文',
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

  void _speakCode() async {
    try {
      final code = await CodeRepository.getSourceCode(widget.filePath);
      if (code.isNotEmpty) {
        String textToSpeak;
        
        if (widget.language == 'markdown') {
          // 对于markdown文件，朗读内容
          textToSpeak = _processMarkdownForSpeech(code);
          print(textToSpeak);
        } else {
          // 对于代码文件，朗读文件信息和主要结构
          textToSpeak = _processCodeForSpeech(code);
        }
        
        await _flutterTts.speak(textToSpeak);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('文件为空，无法朗读')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('朗读失败: $e')),
        );
      }
    }
  }

  String _processMarkdownForSpeech(String markdown) {
    // 移除markdown标记，保留纯文本内容
    return markdown
        .replaceAll(RegExp(r'#+\s*'), '') // 移除标题标记
        .replaceAll(RegExp(r'!+\s*'), '') // 移除变量标记
        .replaceAll(RegExp(r'\^+\s*'), '') // 移除变量标记
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), '') // 移除粗体标记
        .replaceAll(RegExp(r'\*(.*?)\*'), '') // 移除斜体标记
        .replaceAll(RegExp(r'`(.*?)`'), '') // 移除代码标记
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), '') // 移除链接标记
        .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '') // 移除图片标记
        .trim();
  }

  String _processCodeForSpeech(String code) {
    // 分析代码结构并生成描述性文本
    final lines = code.split('\n');
    final totalLines = lines.length;
    
    // 统计主要元素
    int classCount = 0;
    int functionCount = 0;
    int importCount = 0;
    int commentCount = 0;
    
    for (String line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('class ')) classCount++;
      if (trimmedLine.startsWith('void ') || trimmedLine.startsWith('String ') || 
          trimmedLine.startsWith('int ') || trimmedLine.startsWith('bool ') ||
          trimmedLine.startsWith('Widget ') || trimmedLine.startsWith('Future<')) functionCount++;
      if (trimmedLine.startsWith('import ')) importCount++;
      if (trimmedLine.startsWith('//') || trimmedLine.startsWith('/*')) commentCount++;
    }
    
    String description = '文件 ${widget.title}，共 $totalLines 行代码';
    
    if (importCount > 0) description += '，包含 $importCount 个导入语句';
    if (classCount > 0) description += '，定义了 $classCount 个类';
    if (functionCount > 0) description += '，包含 $functionCount 个函数';
    if (commentCount > 0) description += '，有 $commentCount 行注释';
    
    description += '。这是一个 ${widget.language} 文件。';
    
    return description;
  }

  void _stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('停止朗读失败: $e')),
        );
      }
    }
  }
}

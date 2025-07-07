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

  void _initTts() async {
    _flutterTts = FlutterTts();
    
    // 配置TTS引擎
    await _configureTtsEngine();

    // 配置语言
    await _configureLanguage();

    // 配置语音参数
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // 设置事件处理器
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

  Future<void> _configureTtsEngine() async {
    try {
      // 检查平台，iOS不支持getEngines方法
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        print('iOS平台，使用系统默认TTS引擎');
        return;
      }

      // Android平台才尝试设置特定引擎
      try {
        var engines = await _flutterTts.getEngines;
        print('可用TTS引擎: $engines');

        // 优先尝试Google TTS引擎（最通用）
        if (engines.contains('com.google.android.tts')) {
          await _flutterTts.setEngine('com.google.android.tts');
          print('使用Google TTS引擎');
          return;
        }

        // 尝试其他常见的TTS引擎
        List<String> commonEngines = [
          'com.android.tts',
          'com.samsung.tts',
          'com.huawei.tts',
          'com.oppo.tts',
          'com.vivo.tts',
          'com.miui.tts',
        ];

        for (String engine in commonEngines) {
          if (engines.contains(engine)) {
            try {
              await _flutterTts.setEngine(engine);
              print('使用TTS引擎: $engine');
              return;
            } catch (e) {
              print('设置引擎 $engine 失败: $e');
            }
          }
        }
        
        print('使用系统默认TTS引擎');
      } catch (e) {
        print('获取TTS引擎列表失败: $e，使用系统默认引擎');
      }
    } catch (e) {
      print('配置TTS引擎时出错: $e');
    }
  }

  Future<void> _configureLanguage() async {
    try {
      // 检查中文是否可用
      var ttsStatus = await _flutterTts.isLanguageAvailable("zh-CN");
      if (ttsStatus == 1) {
        await _flutterTts.setLanguage("zh-CN");
        print('设置中文语音');
      } else {
        // 如果中文不可用，尝试英文
        ttsStatus = await _flutterTts.isLanguageAvailable("en-US");
        if (ttsStatus == 1) {
          await _flutterTts.setLanguage("en-US");
          print('设置英文语音');
        } else {
          // 使用系统默认语言
          await _flutterTts.setLanguage("");
          print('使用系统默认语音');
        }
      }
    } catch (e) {
      print('配置语言时出错: $e');
    }
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
              icon: const Icon(Icons.bug_report),
              onPressed: _testTts,
              tooltip: '测试TTS',
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
        } else {
          // 对于代码文件，朗读文件信息和主要结构
          textToSpeak = _processCodeForSpeech(code);
        }
        
        print('准备朗读文本: $textToSpeak');
        
        // 检查平台并获取TTS信息
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          print('iOS平台TTS朗读');
        } else {
          try {
            var engines = await _flutterTts.getEngines;
            var languages = await _flutterTts.getLanguages;
            print('TTS Engines: $engines');
            print('TTS Languages: $languages');
          } catch (e) {
            print('获取TTS信息失败: $e');
          }
        }
        
        // 尝试朗读
        var result = await _flutterTts.speak(textToSpeak);
        print('TTS Speak Result: $result');
        
        if (result != 1) {
          throw Exception('TTS朗读失败，返回码: $result');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('文件为空，无法朗读')),
          );
        }
      }
    } catch (e) {
      print('TTS Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('朗读失败: $e'),
            duration: const Duration(seconds: 5),
          ),
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

    String description = '${widget.title}，这是一个 ${widget.language} 文件。共 $totalLines 行代码';

    for (String line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('class ')) classCount++;
      if (trimmedLine.startsWith('void ') ||
          trimmedLine.startsWith('String ') ||
          trimmedLine.startsWith('int ') || trimmedLine.startsWith('bool ') ||
          trimmedLine.startsWith('Widget ') ||
          trimmedLine.startsWith('Future<')) functionCount++;
      if (trimmedLine.startsWith('import ')) importCount++;
      if (trimmedLine.startsWith('//') || trimmedLine.startsWith('/*')) {
        commentCount++;
        description += trimmedLine.replaceAll('/', '');
      }
    }

    if (importCount > 0) description += '，包含 $importCount 个导入语句';
    if (classCount > 0) description += '，定义了 $classCount 个类';
    if (functionCount > 0) description += '，包含 $functionCount 个函数';
    if (commentCount > 0) description += '，有 $commentCount 行注释';

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

  void _testTts() async {
    try {
      print('开始TTS测试...');
      
      String message = 'TTS测试';

      // 检查平台
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        print('iOS平台TTS测试');

        // iOS平台直接测试朗读
        var result = await _flutterTts.speak('测试TTS功能');
        print('iOS TTS测试结果: $result');

        if (result == 1) {
          message += '成功，使用iOS系统TTS';
        } else {
          message += '失败，返回码: $result';
        }
      } else {
        // Android平台
        try {
          var engines = await _flutterTts.getEngines;
          print('可用TTS引擎: $engines');

          // 检查常见TTS引擎
          bool hasGoogleTts = engines.contains('com.google.android.tts');
          bool hasSystemTts = engines.contains('com.android.tts');

          print('Google TTS引擎可用: $hasGoogleTts');
          print('系统TTS引擎可用: $hasSystemTts');
          
          // 测试简单的文本朗读
          var result = await _flutterTts.speak('测试TTS功能');
          print('Android TTS测试结果: $result');
          
          if (result == 1) {
            message += '成功';
            if (hasGoogleTts) {
              message += '，使用Google TTS引擎';
            } else if (hasSystemTts) {
              message += '，使用系统TTS引擎';
            } else {
              message += '，使用默认引擎';
            }
          } else {
            message += '失败，返回码: $result';
          }
        } catch (e) {
          print('Android TTS引擎检测失败: $e');
          // 即使引擎检测失败，也尝试朗读
          var result = await _flutterTts.speak('测试TTS功能');
          if (result == 1) {
            message += '成功，使用默认引擎';
          } else {
            message += '失败，返回码: $result';
          }
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      print('TTS测试错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TTS测试错误: $e')),
        );
      }
    }
  }
}

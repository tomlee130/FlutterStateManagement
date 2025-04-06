import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';

class SyntaxHighlighterView extends StatelessWidget {
  final String code;
  final String language;
  final bool isDarkMode;

  const SyntaxHighlighterView({
    Key? key,
    required this.code,
    this.language = 'dart',
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 根据是否是深色模式选择主题
    final theme = isDarkMode ? atomOneDarkTheme : githubTheme;

    // 为markdown添加自定义样式
    Map<String, TextStyle> finalTheme = Map.from(theme);
    if (language == 'markdown') {
      finalTheme.addAll({
        if (isDarkMode)
          'header': const TextStyle(
            color: Color(0xFF61AFEF),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          )
        else
          'header': TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        'link': TextStyle(
          color: isDarkMode ? Colors.lightBlue.shade300 : Colors.blue.shade700,
          decoration: TextDecoration.underline,
        ),
        'quote': TextStyle(
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          fontStyle: FontStyle.italic,
        ),
        'emphasis': const TextStyle(
          fontStyle: FontStyle.italic,
        ),
        'strong': const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      });
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDarkMode ? const Color(0xFF282C34) : const Color(0xFFF6F8FA),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: HighlightView(
          code,
          language: language,
          theme: finalTheme,
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

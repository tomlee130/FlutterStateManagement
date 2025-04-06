import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownViewer extends StatelessWidget {
  final String markdown;
  final bool isDarkMode;

  const MarkdownViewer({
    Key? key,
    required this.markdown,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF8F8F8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 4/5,
      child: Markdown(
        data: markdown,
        selectable: true,
        extensionSet: md.ExtensionSet.gitHubWeb,
        styleSheet: MarkdownStyleSheet(
          // 文本样式
          h1: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.lightBlue.shade300 : Colors.blue.shade800,
          ),
          h2: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.lightBlue.shade300 : Colors.blue.shade800,
          ),
          h3: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.lightBlue.shade200 : Colors.blue.shade700,
          ),
          h4: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.lightBlue.shade200 : Colors.blue.shade700,
          ),
          p: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
          ),
          strong: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          em: const TextStyle(
            fontStyle: FontStyle.italic,
          ),
          listBullet: TextStyle(
            color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
          ),
          blockquote: TextStyle(
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            fontStyle: FontStyle.italic,
            decoration: TextDecoration.none,
          ),
          code: TextStyle(
            backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            color: isDarkMode ? Colors.lightGreen.shade300 : Colors.deepPurple,
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 1,
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
          ),
          a: TextStyle(
            color: isDarkMode ? Colors.lightBlue.shade300 : Colors.blue.shade700,
            decoration: TextDecoration.underline,
          ),
          // 表格样式
          tableBorder: TableBorder.all(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          tableHead: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          tableBody: TextStyle(
            color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
      ),
    );
  }
}

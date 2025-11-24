import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/data/models/chat_message.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final timeFormat = DateFormat('HH:mm');

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isUser) ...[
          // AI Avatar
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8, bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryViolet, Color(0xFF8B7FFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryViolet.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.primaryViolet : AppColors.pureWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isUser 
                          ? AppColors.primaryViolet.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image if present
                    if (message.imagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(message.imagePath!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    // Message content
                    if (isUser)
                      SelectableText(
                        message.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      )
                    else
                      _SimpleMarkdownRenderer(
                        content: message.content,
                        baseStyle: const TextStyle(
                          color: AppColors.deepSlate,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Timestamp
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  timeFormat.format(message.createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.softGrey.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (isUser) ...[
          // User Avatar
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(left: 8, bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.lavenderMist,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 18,
              color: AppColors.primaryViolet,
            ),
          ),
        ],
      ],
    );
  }
}

class _SimpleMarkdownRenderer extends StatelessWidget {
  final String content;
  final TextStyle? baseStyle;

  const _SimpleMarkdownRenderer({
    required this.content,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    final lines = content.split('\n');

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Block LaTeX
      if (line.trim().startsWith(r'$$') && line.trim().endsWith(r'$$')) {
        final latex = line.trim().substring(2, line.trim().length - 2);
        widgets.add(_buildBlockLatex(latex));
        continue;
      }

      // Headings
      if (line.startsWith('### ')) {
        widgets.add(_buildHeading(context, line.substring(4), 3));
      } else if (line.startsWith('## ')) {
        widgets.add(_buildHeading(context, line.substring(3), 2));
      } else if (line.startsWith('# ')) {
        widgets.add(_buildHeading(context, line.substring(2), 1));
      } else if (line.startsWith('> ')) {
        widgets.add(_buildBlockquote(context, line.substring(2)));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        widgets.add(_buildListItem(context, line.substring(2)));
      } else if (RegExp(r'^\d+\. ').hasMatch(line)) {
        final match = RegExp(r'^(\d+)\. (.*)').firstMatch(line);
        if (match != null) {
          widgets.add(_buildNumberedListItem(context, match.group(1)!, match.group(2)!));
        }
      } else {
        widgets.add(_buildParagraph(context, line));
      }
    }

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _buildBlockLatex(String latex) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lavenderMist.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            latex.trim(),
            textStyle: const TextStyle(fontSize: 16, color: AppColors.deepSlate),
            onErrorFallback: (error) => Text(
              latex,
              style: const TextStyle(fontFamily: 'monospace', color: AppColors.softGrey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(BuildContext context, String text, int level) {
    final styles = [
      Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.deepSlate,
          ),
      Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.deepSlate,
          ),
      Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.deepSlate,
          ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: _buildTextWithInlineLatex(text, styles[level - 1]!),
    );
  }

  Widget _buildBlockquote(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.primaryViolet.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),
      child: _buildTextWithInlineLatex(
        text,
        baseStyle?.copyWith(
          color: AppColors.softGrey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 8),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primaryViolet,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: _buildTextWithInlineLatex(text, baseStyle)),
        ],
      ),
    );
  }

  Widget _buildNumberedListItem(BuildContext context, String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(right: 8),
            child: Text(
              '$number.',
              style: const TextStyle(
                color: AppColors.primaryViolet,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: _buildTextWithInlineLatex(text, baseStyle)),
        ],
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: _buildTextWithInlineLatex(text, baseStyle),
    );
  }

  Widget _buildTextWithInlineLatex(String text, TextStyle? style) {
    // Check for inline latex $...$
    if (!text.contains(r'$')) {
      return Text(_parseBoldItalic(text), style: style);
    }

    final parts = <InlineSpan>[];
    final regex = RegExp(r'\$([^\$]+)\$');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        parts.add(TextSpan(text: text.substring(lastEnd, match.start), style: style));
      }

      final latex = match.group(1)!;
      parts.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Math.tex(
            latex,
            textStyle: style?.copyWith(color: AppColors.deepSlate),
            onErrorFallback: (error) => Text(
              '\$$latex\$',
              style: style?.copyWith(color: Colors.red, fontFamily: 'monospace'),
            ),
          ),
        ),
      ));

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      parts.add(TextSpan(text: text.substring(lastEnd), style: style));
    }

    return Text.rich(TextSpan(children: parts));
  }

  String _parseBoldItalic(String text) {
    return text.replaceAll('**', '').replaceAll('*', '');
  }
}

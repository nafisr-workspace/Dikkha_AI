import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:dikkhaai/app/theme.dart';

class MarkdownReader extends StatefulWidget {
  final String content;
  final void Function(String)? onTextSelected;

  const MarkdownReader({
    super.key,
    required this.content,
    this.onTextSelected,
  });

  @override
  State<MarkdownReader> createState() => _MarkdownReaderState();
}

class _MarkdownReaderState extends State<MarkdownReader> {
  String _selectedText = '';

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      onSelectionChanged: (selection) {
        if (selection != null) {
          _selectedText = selection.plainText;
        }
      },
      contextMenuBuilder: (context, editableTextState) {
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: editableTextState.contextMenuAnchors,
          buttonItems: [
            ContextMenuButtonItem(
              onPressed: () {
                editableTextState.copySelection(SelectionChangedCause.toolbar);
              },
              type: ContextMenuButtonType.copy,
            ),
            ContextMenuButtonItem(
              onPressed: () {
                if (_selectedText.isNotEmpty) {
                  widget.onTextSelected?.call(_selectedText);
                }
                editableTextState.hideToolbar();
              },
              label: 'Ask AI',
            ),
          ],
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final parts = _parseContent(widget.content);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) => _buildPart(part)).toList(),
    );
  }

  List<_ContentPart> _parseContent(String content) {
    final parts = <_ContentPart>[];
    final lines = content.split('\n');
    final buffer = StringBuffer();

    for (final line in lines) {
      // Check for block LaTeX
      if (line.trim().startsWith(r'$$') && line.trim().endsWith(r'$$')) {
        // Single line block latex
        if (buffer.isNotEmpty) {
          parts.add(_ContentPart(buffer.toString(), _ContentType.text));
          buffer.clear();
        }
        final latex = line.trim().substring(2, line.trim().length - 2);
        parts.add(_ContentPart(latex, _ContentType.blockLatex));
      } else if (line.trim().startsWith(r'$$')) {
        // Start of block latex
        if (buffer.isNotEmpty) {
          parts.add(_ContentPart(buffer.toString(), _ContentType.text));
          buffer.clear();
        }
        buffer.write(line.trim().substring(2));
      } else if (line.trim().endsWith(r'$$') && parts.isNotEmpty) {
        // End of block latex
        buffer.write(line.trim().substring(0, line.trim().length - 2));
        parts.add(_ContentPart(buffer.toString(), _ContentType.blockLatex));
        buffer.clear();
      } else {
        buffer.writeln(line);
      }
    }

    if (buffer.isNotEmpty) {
      parts.add(_ContentPart(buffer.toString(), _ContentType.text));
    }

    return parts;
  }

  Widget _buildPart(_ContentPart part) {
    switch (part.type) {
      case _ContentType.blockLatex:
        return _buildBlockLatex(part.content);
      case _ContentType.text:
        return _buildTextContent(part.content);
    }
  }

  Widget _buildBlockLatex(String latex) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lavenderMist.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            latex.trim(),
            textStyle: const TextStyle(
              fontSize: 18,
              color: AppColors.deepSlate,
            ),
            onErrorFallback: (error) => Text(
              latex,
              style: const TextStyle(
                color: AppColors.softGrey,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(String content) {
    final widgets = <Widget>[];
    final lines = content.split('\n');

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Parse headings
      if (line.startsWith('# ')) {
        widgets.add(_buildHeading(line.substring(2), 1));
      } else if (line.startsWith('## ')) {
        widgets.add(_buildHeading(line.substring(3), 2));
      } else if (line.startsWith('### ')) {
        widgets.add(_buildHeading(line.substring(4), 3));
      } else if (line.startsWith('#### ')) {
        widgets.add(_buildHeading(line.substring(5), 4));
      } else if (line.startsWith('> ')) {
        widgets.add(_buildBlockquote(line.substring(2)));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        widgets.add(_buildListItem(line.substring(2)));
      } else if (RegExp(r'^\d+\. ').hasMatch(line)) {
        final match = RegExp(r'^(\d+)\. (.*)').firstMatch(line);
        if (match != null) {
          widgets.add(_buildNumberedListItem(match.group(1)!, match.group(2)!));
        }
      } else if (line.startsWith('---')) {
        widgets.add(const Divider(height: 24));
      } else {
        widgets.add(_buildParagraph(line));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildHeading(String text, int level) {
    final styles = [
      Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.deepSlate,
          ),
      Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.deepSlate,
          ),
      Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.deepSlate,
          ),
      Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.deepSlate,
          ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: _buildRichText(text, styles[level - 1]!),
    );
  }

  Widget _buildBlockquote(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.primaryViolet.withValues(alpha: 0.5),
            width: 4,
          ),
        ),
      ),
      child: _buildRichText(
        text,
        Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.softGrey,
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primaryViolet, fontSize: 16)),
          Expanded(child: _buildRichText(text, null)),
        ],
      ),
    );
  }

  Widget _buildNumberedListItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number. ', style: const TextStyle(color: AppColors.primaryViolet, fontSize: 16)),
          Expanded(child: _buildRichText(text, null)),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: _buildRichText(text, null),
    );
  }

  Widget _buildRichText(String text, TextStyle? baseStyle) {
    final style = baseStyle ?? Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.6,
          color: AppColors.deepSlate,
        );

    // Check for inline latex $...$
    if (text.contains(r'$')) {
      return _buildTextWithInlineLatex(text, style);
    }

    // Check for bold and italic
    return Text.rich(
      _parseInlineFormatting(text, style!),
      style: style,
    );
  }

  Widget _buildTextWithInlineLatex(String text, TextStyle? style) {
    final parts = <InlineSpan>[];
    final regex = RegExp(r'\$([^\$]+)\$');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before match
      if (match.start > lastEnd) {
        parts.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: style,
        ));
      }
      
      // Add latex as widget span
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
              style: style?.copyWith(
                color: Colors.red,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ));
      
      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastEnd),
        style: style,
      ));
    }

    return Text.rich(TextSpan(children: parts));
  }

  TextSpan _parseInlineFormatting(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    
    // Simple bold parsing
    final boldRegex = RegExp(r'\*\*([^\*]+)\*\*');
    
    String remaining = text;
    
    // Parse bold
    while (boldRegex.hasMatch(remaining)) {
      final match = boldRegex.firstMatch(remaining)!;
      if (match.start > 0) {
        spans.add(TextSpan(text: remaining.substring(0, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));
      remaining = remaining.substring(match.end);
    }
    
    if (spans.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }
    
    if (remaining.isNotEmpty) {
      spans.add(TextSpan(text: remaining));
    }
    
    return TextSpan(children: spans, style: baseStyle);
  }
}

enum _ContentType { text, blockLatex }

class _ContentPart {
  final String content;
  final _ContentType type;

  _ContentPart(this.content, this.type);
}

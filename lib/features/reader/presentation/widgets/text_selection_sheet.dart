import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/app/router.dart';
import 'package:dikkhaai/features/chat/providers/chat_provider.dart';

class TextSelectionSheet extends ConsumerStatefulWidget {
  final String selectedText;
  final String subject;

  const TextSelectionSheet({
    super.key,
    required this.selectedText,
    required this.subject,
  });

  @override
  ConsumerState<TextSelectionSheet> createState() => _TextSelectionSheetState();
}

class _TextSelectionSheetState extends ConsumerState<TextSelectionSheet> {
  final _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  String get _truncatedText {
    if (widget.selectedText.length <= 150) {
      return widget.selectedText;
    }
    return '${widget.selectedText.substring(0, 150)}...';
  }

  void _sendToChat(String actionType) {
    Navigator.pop(context);
    
    String prompt;
    switch (actionType) {
      case 'explain':
        prompt = 'এই অংশটি ব্যাখ্যা করো (Explain this):\n\n"${widget.selectedText}"';
        break;
      case 'solve':
        prompt = 'এটি সমাধান করো (Solve this):\n\n"${widget.selectedText}"';
        break;
      case 'custom':
        prompt = '${_promptController.text}\n\nContext:\n"${widget.selectedText}"';
        break;
      default:
        prompt = widget.selectedText;
    }

    // Set the pending message in chat provider
    ref.read(pendingChatMessageProvider.notifier).state = PendingChatMessage(
      message: prompt,
      subject: widget.subject,
      selectedText: widget.selectedText,
    );

    // Navigate to chat
    context.go('${AppRoutes.main}/chat');
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.paleGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected text preview
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lavenderMist.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.format_quote,
                                size: 16,
                                color: AppColors.softGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Selected Text',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: AppColors.softGrey,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _truncatedText,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Quick action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.lightbulb_outline,
                            label: 'Explain More',
                            onTap: () => _sendToChat('explain'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.calculate_outlined,
                            label: 'Solve It',
                            onTap: () => _sendToChat('solve'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Custom prompt
                    Text(
                      'Or ask a custom question:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promptController,
                            decoration: InputDecoration(
                              hintText: 'Ask anything about this selection...',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.paleGrey),
                              ),
                            ),
                            maxLines: 2,
                            minLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: AppColors.primaryViolet,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: _promptController.text.isNotEmpty
                                ? () => _sendToChat('custom')
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              child: Icon(
                                Icons.send,
                                color: _promptController.text.isNotEmpty
                                    ? AppColors.onPrimary
                                    : AppColors.onPrimary.withValues(alpha: 0.5),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pureWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.paleGrey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primaryViolet,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryViolet,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:dikkhaai/app/theme.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttachImage;
  final VoidCallback onVoiceInput;
  final bool isEnabled;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttachImage,
    required this.onVoiceInput,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          top: BorderSide(
            color: AppColors.paleGrey.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: isEnabled ? onAttachImage : null,
              color: AppColors.softGrey,
              tooltip: 'Attach image',
            ),
            // Voice button
            IconButton(
              icon: const Icon(Icons.mic_none),
              onPressed: isEnabled ? onVoiceInput : null,
              color: AppColors.softGrey,
              tooltip: 'Voice input',
            ),
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.creamyWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.paleGrey),
                ),
                child: TextField(
                  controller: controller,
                  enabled: isEnabled,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: TextStyle(
                      color: AppColors.softGrey.withValues(alpha: 0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            Material(
              color: AppColors.primaryViolet,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: isEnabled ? onSend : null,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.send,
                    color: isEnabled
                        ? AppColors.onPrimary
                        : AppColors.onPrimary.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


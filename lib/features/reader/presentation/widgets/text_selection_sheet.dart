import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/app/router.dart';
import 'package:dikkhaai/features/chat/providers/chat_provider.dart';
import 'package:dikkhaai/data/services/ai_service.dart';
import 'package:dikkhaai/data/services/storage_service.dart';
import 'package:dikkhaai/data/models/quiz.dart';
import 'package:dikkhaai/data/models/flashcard.dart';

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
  bool _isGeneratingQuiz = false;
  bool _isGeneratingFlashcards = false;

  @override
  void initState() {
    super.initState();
    _promptController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _promptController.removeListener(_onTextChanged);
    _promptController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _fillPrompt(String prompt) {
    _promptController.text = prompt;
    _promptController.selection = TextSelection.fromPosition(
      TextPosition(offset: prompt.length),
    );
  }

  String get _truncatedText {
    // Limit to ~80 chars for 2-3 lines
    if (widget.selectedText.length <= 80) {
      return widget.selectedText;
    }
    return '${widget.selectedText.substring(0, 80)}...';
  }

  void _sendToChat(String actionType) {
    // Capture references before popping
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    
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

    // Pop the bottom sheet first
    navigator.pop();
    
    // Navigate to chat
    router.go('${AppRoutes.main}/chat');
  }

  Future<void> _generateQuiz() async {
    if (_isGeneratingQuiz) return;

    // Capture references before async operation
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() {
      _isGeneratingQuiz = true;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final storageService = ref.read(storageServiceProvider);

      // Generate quiz questions using AI
      final questions = await aiService.generateQuiz(
        selectedText: widget.selectedText,
        subject: widget.subject,
      );

      // Create and save quiz
      final quiz = Quiz(
        id: const Uuid().v4(),
        subject: widget.subject,
        sourceText: widget.selectedText,
        questions: questions,
        createdAt: DateTime.now(),
      );

      await storageService.saveQuiz(quiz);

      // Pop the bottom sheet first
      navigator.pop();

      // Show success snackbar
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Quiz created with ${questions.length} questions!'),
              ),
              TextButton(
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                  router.go('${AppRoutes.main}/study');
                },
                child: const Text(
                  'View',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryViolet,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingQuiz = false;
        });
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to generate quiz: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateFlashcards() async {
    if (_isGeneratingFlashcards) return;

    // Capture references before async operation
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() {
      _isGeneratingFlashcards = true;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final storageService = ref.read(storageServiceProvider);

      // Generate flashcards using AI
      final cards = await aiService.generateFlashcards(
        selectedText: widget.selectedText,
        subject: widget.subject,
      );

      // Create and save flashcard set
      final flashcardSet = FlashcardSet(
        id: const Uuid().v4(),
        subject: widget.subject,
        sourceText: widget.selectedText,
        cards: cards,
        createdAt: DateTime.now(),
      );

      await storageService.saveFlashcardSet(flashcardSet);

      // Pop the bottom sheet first
      navigator.pop();

      // Show success snackbar
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Created ${cards.length} flashcards!'),
              ),
              TextButton(
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                  router.go('${AppRoutes.main}/study');
                },
                child: const Text(
                  'View',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryViolet,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingFlashcards = false;
        });
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to generate flashcards: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
              margin: const EdgeInsets.symmetric(vertical: 10),
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected text preview - compact
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lavenderMist.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: 18,
                            color: AppColors.primaryViolet.withOpacity(0.5),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _truncatedText,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    height: 1.4,
                                    color: AppColors.deepSlate.withOpacity(0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Study Materials Section
                    Text(
                      'Generate Study Materials',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepSlate,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _GenerateButton(
                            icon: Icons.quiz_outlined,
                            label: 'Create Quiz',
                            sublabel: '3 questions',
                            isLoading: _isGeneratingQuiz,
                            color: const Color(0xFF6366F1),
                            onTap: _generateQuiz,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GenerateButton(
                            icon: Icons.style_outlined,
                            label: 'Flashcards',
                            sublabel: '3 cards',
                            isLoading: _isGeneratingFlashcards,
                            color: const Color(0xFF10B981),
                            onTap: _generateFlashcards,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Ask AI Section
                    Text(
                      'Ask AI',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepSlate,
                          ),
                    ),
                    const SizedBox(height: 12),
                    // Quick prompt suggestions
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PromptSuggestionChip(
                          icon: Icons.lightbulb_outline,
                          label: 'Explain this',
                          onTap: () => _fillPrompt('এই অংশটি ব্যাখ্যা করো (Explain this)'),
                        ),
                        _PromptSuggestionChip(
                          icon: Icons.calculate_outlined,
                          label: 'Solve it',
                          onTap: () => _fillPrompt('এটি সমাধান করো (Solve this)'),
                        ),
                        _PromptSuggestionChip(
                          icon: Icons.summarize_outlined,
                          label: 'Summarize',
                          onTap: () => _fillPrompt('এটি সংক্ষেপে বলো (Summarize this)'),
                        ),
                        _PromptSuggestionChip(
                          icon: Icons.help_outline,
                          label: 'Why is this important?',
                          onTap: () => _fillPrompt('এটি কেন গুরুত্বপূর্ণ? (Why is this important?)'),
                        ),
                        _PromptSuggestionChip(
                          icon: Icons.extension_outlined,
                          label: 'Give examples',
                          onTap: () => _fillPrompt('এর উদাহরণ দাও (Give examples)'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Input field with send button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _promptController.text.isNotEmpty
                              ? AppColors.primaryViolet
                              : AppColors.paleGrey,
                          width: _promptController.text.isNotEmpty ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryViolet.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _promptController,
                            decoration: InputDecoration(
                              hintText: 'Type your question here...',
                              hintStyle: TextStyle(
                                color: AppColors.softGrey.withOpacity(0.7),
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                              border: InputBorder.none,
                            ),
                            maxLines: 2,
                            minLines: 1,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Divider(
                              height: 1,
                              color: AppColors.paleGrey.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Send button row
                          Container(
                            padding: const EdgeInsets.fromLTRB(12, 0, 8, 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 16,
                                  color: AppColors.primaryViolet.withOpacity(0.5),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'AI will answer based on selected text',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.softGrey,
                                        fontSize: 11,
                                      ),
                                ),
                                const Spacer(),
                                Material(
                                  color: _promptController.text.isNotEmpty
                                      ? AppColors.primaryViolet
                                      : AppColors.paleGrey.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    onTap: _promptController.text.isNotEmpty
                                        ? () => _sendToChat('custom')
                                        : null,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Ask',
                                            style: TextStyle(
                                              color: _promptController.text.isNotEmpty
                                                  ? AppColors.onPrimary
                                                  : AppColors.softGrey,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.send_rounded,
                                            color: _promptController.text.isNotEmpty
                                                ? AppColors.onPrimary
                                                : AppColors.softGrey,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

class _PromptSuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PromptSuggestionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pureWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryViolet.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.primaryViolet,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

class _GenerateButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool isLoading;
  final Color color;
  final VoidCallback onTap;

  const _GenerateButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.isLoading,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Generating...',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sublabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color.withOpacity(0.7),
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}


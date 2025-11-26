import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/data/models/flashcard.dart';

class FlashcardReviewScreen extends ConsumerStatefulWidget {
  final FlashcardSet flashcardSet;

  const FlashcardReviewScreen({super.key, required this.flashcardSet});

  @override
  ConsumerState<FlashcardReviewScreen> createState() =>
      _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends ConsumerState<FlashcardReviewScreen>
    with SingleTickerProviderStateMixin {
  int _currentCardIndex = 0;
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Flashcard get _currentCard => widget.flashcardSet.cards[_currentCardIndex];

  void _flipCard() {
    if (_flipController.isAnimating) return;

    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _nextCard() {
    if (_currentCardIndex < widget.flashcardSet.cards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _isFlipped = false;
      });
      _flipController.reset();
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
        _isFlipped = false;
      });
      _flipController.reset();
    }
  }

  Color get _subjectColor {
    switch (widget.flashcardSet.subject.toLowerCase()) {
      case 'physics':
        return const Color(0xFF6366F1);
      case 'chemistry':
        return const Color(0xFF10B981);
      case 'biology':
        return const Color(0xFFF59E0B);
      case 'mathematics':
      case 'higher math':
        return const Color(0xFFEF4444);
      case 'bangla':
        return const Color(0xFF8B5CF6);
      case 'english':
        return const Color(0xFF3B82F6);
      default:
        return AppColors.primaryViolet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _subjectColor.withOpacity(0.1),
              AppColors.creamyWhite,
              _subjectColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.pureWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.flashcardSet.subject,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _subjectColor,
                                    ),
                          ),
                          Text(
                            'Card ${_currentCardIndex + 1} of ${widget.flashcardSet.cards.length}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.softGrey,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _subjectColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.style_rounded,
                            size: 18,
                            color: _subjectColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.flashcardSet.cards.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _subjectColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Progress dots
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.flashcardSet.cards.length,
                    (index) => Container(
                      width: index == _currentCardIndex ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == _currentCardIndex
                            ? _subjectColor
                            : _subjectColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Flashcard
              Expanded(
                child: GestureDetector(
                  onTap: _flipCard,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      _previousCard();
                    } else if (details.primaryVelocity! < 0) {
                      _nextCard();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, child) {
                        final angle = _flipAnimation.value * pi;
                        final isFront = angle < pi / 2;

                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          child: isFront
                              ? _buildCardFace(
                                  _currentCard.front,
                                  'Question',
                                  Icons.help_outline_rounded,
                                  true,
                                )
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _buildCardFace(
                                    _currentCard.back,
                                    'Answer',
                                    Icons.lightbulb_outline_rounded,
                                    false,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Hint text
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 16,
                      color: AppColors.softGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to flip • Swipe to navigate',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.softGrey,
                          ),
                    ),
                  ],
                ),
              ),
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _currentCardIndex > 0 ? _previousCard : null,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _subjectColor,
                          side: BorderSide(
                            color: _currentCardIndex > 0
                                ? _subjectColor
                                : AppColors.paleGrey,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _currentCardIndex <
                                widget.flashcardSet.cards.length - 1
                            ? _nextCard
                            : () => Navigator.pop(context),
                        icon: Icon(
                          _currentCardIndex <
                                  widget.flashcardSet.cards.length - 1
                              ? Icons.arrow_forward_rounded
                              : Icons.check_rounded,
                        ),
                        label: Text(
                          _currentCardIndex <
                                  widget.flashcardSet.cards.length - 1
                              ? 'Next'
                              : 'Done',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: _subjectColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildCardFace(
    String content,
    String label,
    IconData icon,
    bool isFront,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isFront ? AppColors.pureWhite : _subjectColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _subjectColor.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isFront
              ? _subjectColor.withOpacity(0.2)
              : _subjectColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Label header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _subjectColor.withOpacity(isFront ? 0.1 : 0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: _subjectColor,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _subjectColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Text(
                  content,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.deepSlate,
                        height: 1.6,
                        fontSize: 18,
                      ),
                ),
              ),
            ),
          ),
          // Flip indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flip_rounded,
                  size: 16,
                  color: AppColors.softGrey.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap to see ${isFront ? 'answer' : 'question'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.softGrey.withOpacity(0.5),
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


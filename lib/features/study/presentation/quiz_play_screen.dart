import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/data/models/quiz.dart';
import 'package:dikkhaai/data/services/storage_service.dart';

class QuizPlayScreen extends ConsumerStatefulWidget {
  final Quiz quiz;

  const QuizPlayScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  int _score = 0;
  bool _isCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  QuizQuestion get _currentQuestion =>
      widget.quiz.questions[_currentQuestionIndex];

  void _selectOption(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
      if (index == _currentQuestion.correctIndex) {
        _score++;
      }
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _hasAnswered = false;
      });
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    setState(() {
      _isCompleted = true;
    });

    // Update quiz score in storage
    final updatedQuiz = widget.quiz.copyWith(
      lastScore: _score,
      totalAttempts: (widget.quiz.totalAttempts ?? 0) + 1,
    );
    ref.read(storageServiceProvider).saveQuiz(updatedQuiz);
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _hasAnswered = false;
      _score = 0;
      _isCompleted = false;
    });
  }

  Color get _subjectColor {
    switch (widget.quiz.subject.toLowerCase()) {
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
          child: _isCompleted ? _buildResultScreen() : _buildQuizScreen(),
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    return Column(
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
                      widget.quiz.subject,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _subjectColor,
                          ),
                    ),
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      Icons.stars_rounded,
                      size: 18,
                      color: _subjectColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_score',
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
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:
                  (_currentQuestionIndex + 1) / widget.quiz.questions.length,
              backgroundColor: _subjectColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(_subjectColor),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Question
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _subjectColor.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _subjectColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_currentQuestionIndex + 1}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _subjectColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentQuestion.question,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.deepSlate,
                                  height: 1.5,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Options
                ...List.generate(
                  _currentQuestion.options.length,
                  (index) => _buildOptionButton(index),
                ),
              ],
            ),
          ),
        ),
        // Next button
        if (_hasAnswered)
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _nextQuestion,
                style: FilledButton.styleFrom(
                  backgroundColor: _subjectColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _currentQuestionIndex < widget.quiz.questions.length - 1
                      ? 'Next Question'
                      : 'See Results',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionButton(int index) {
    final isSelected = _selectedOptionIndex == index;
    final isCorrect = index == _currentQuestion.correctIndex;
    final showResult = _hasAnswered;

    Color backgroundColor = AppColors.pureWhite;
    Color borderColor = AppColors.paleGrey;
    Color textColor = AppColors.deepSlate;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green.shade700;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red.shade700;
      }
    } else if (isSelected) {
      backgroundColor = _subjectColor.withOpacity(0.1);
      borderColor = _subjectColor;
      textColor = _subjectColor;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected && showResult ? _scaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => _selectOption(index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected || (showResult && isCorrect)
                              ? borderColor.withOpacity(0.2)
                              : AppColors.lavenderMist.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: showResult
                              ? Icon(
                                  isCorrect
                                      ? Icons.check_rounded
                                      : (isSelected
                                          ? Icons.close_rounded
                                          : null),
                                  color: borderColor,
                                  size: 20,
                                )
                              : Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? _subjectColor
                                        : AppColors.softGrey,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _currentQuestion.options[index],
                          style: TextStyle(
                            color: textColor,
                            fontWeight: isSelected || (showResult && isCorrect)
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultScreen() {
    final percentage = _score / widget.quiz.questions.length;
    final wrongAnswers = widget.quiz.questions.length - _score;
    
    // Determine grade and colors
    String grade;
    String message;
    Color gradeColor;
    IconData gradeIcon;
    
    if (percentage >= 0.9) {
      grade = 'A+';
      message = 'Outstanding! You\'re a genius!';
      gradeColor = const Color(0xFF10B981);
      gradeIcon = Icons.emoji_events_rounded;
    } else if (percentage >= 0.8) {
      grade = 'A';
      message = 'Excellent work! Keep it up!';
      gradeColor = const Color(0xFF10B981);
      gradeIcon = Icons.star_rounded;
    } else if (percentage >= 0.7) {
      grade = 'B';
      message = 'Good job! Almost there!';
      gradeColor = const Color(0xFF3B82F6);
      gradeIcon = Icons.thumb_up_rounded;
    } else if (percentage >= 0.5) {
      grade = 'C';
      message = 'Not bad! Keep practicing!';
      gradeColor = const Color(0xFFF59E0B);
      gradeIcon = Icons.trending_up_rounded;
    } else {
      grade = 'D';
      message = 'Don\'t give up! Try again!';
      gradeColor = const Color(0xFFEF4444);
      gradeIcon = Icons.fitness_center_rounded;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Trophy/Badge Section
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        gradeColor.withOpacity(0.3),
                        gradeColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                // Progress ring
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 12,
                    backgroundColor: AppColors.paleGrey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Grade badge
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gradeColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        gradeIcon,
                        size: 36,
                        color: gradeColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        grade,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: gradeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Percentage
            Text(
              '${(percentage * 100).toInt()}%',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: gradeColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.deepSlate,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 32),
            // Stats Cards
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Quiz Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepSlate,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle_rounded,
                          label: 'Correct',
                          value: '$_score',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.cancel_rounded,
                          label: 'Wrong',
                          value: '$wrongAnswers',
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.quiz_rounded,
                          label: 'Total',
                          value: '${widget.quiz.questions.length}',
                          color: _subjectColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Subject badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _subjectColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.book_rounded,
                    size: 18,
                    color: _subjectColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.quiz.subject,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _subjectColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _restartQuiz,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _subjectColor,
                      side: BorderSide(color: _subjectColor, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Done'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _subjectColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.softGrey,
                ),
          ),
        ],
      ),
    );
  }
}


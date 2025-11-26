import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/data/services/storage_service.dart';
import 'package:dikkhaai/data/models/quiz.dart';
import 'package:dikkhaai/data/models/flashcard.dart';
import 'package:dikkhaai/features/study/presentation/quiz_play_screen.dart';
import 'package:dikkhaai/features/study/presentation/flashcard_review_screen.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F7FF),
            AppColors.creamyWhite,
          ],
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryViolet.withOpacity(0.2),
                            AppColors.lavenderMist,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: AppColors.primaryViolet,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Study Materials',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.deepSlate,
                                ),
                          ),
                          Text(
                            'Quizzes & Flashcards',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.softGrey,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tab bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryViolet.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primaryViolet,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.onPrimary,
                    unselectedLabelColor: AppColors.softGrey,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.quiz_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Quizzes'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.style_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Flashcards'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _QuizzesTab(),
                _FlashcardsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizzesTab extends ConsumerWidget {
  const _QuizzesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final quizzes = storage.getAllQuizzes();

    if (quizzes.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.quiz_outlined,
        title: 'No Quizzes Yet',
        subtitle: 'Select text in the book reader to create quizzes',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return _QuizCard(
          quiz: quiz,
          onTap: () => _openQuiz(context, quiz),
          onDelete: () => _deleteQuiz(context, ref, quiz),
        );
      },
    );
  }

  void _openQuiz(BuildContext context, Quiz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPlayScreen(quiz: quiz),
      ),
    );
  }

  void _deleteQuiz(BuildContext context, WidgetRef ref, Quiz quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text('Are you sure you want to delete this quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(storageServiceProvider).deleteQuiz(quiz.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quiz deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lavenderMist.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.primaryViolet.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepSlate,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.softGrey,
                  ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.go('/main/read'),
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Go to Books'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryViolet,
                side: const BorderSide(color: AppColors.primaryViolet),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashcardsTab extends ConsumerWidget {
  const _FlashcardsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final flashcardSets = storage.getAllFlashcardSets();

    if (flashcardSets.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.style_outlined,
        title: 'No Flashcards Yet',
        subtitle: 'Select text in the book reader to create flashcards',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: flashcardSets.length,
      itemBuilder: (context, index) {
        final set = flashcardSets[index];
        return _FlashcardSetCard(
          flashcardSet: set,
          onTap: () => _openFlashcards(context, set),
          onDelete: () => _deleteFlashcardSet(context, ref, set),
        );
      },
    );
  }

  void _openFlashcards(BuildContext context, FlashcardSet set) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardReviewScreen(flashcardSet: set),
      ),
    );
  }

  void _deleteFlashcardSet(
      BuildContext context, WidgetRef ref, FlashcardSet set) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flashcards'),
        content:
            const Text('Are you sure you want to delete this flashcard set?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(storageServiceProvider).deleteFlashcardSet(set.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Flashcard set deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lavenderMist.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.primaryViolet.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepSlate,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.softGrey,
                  ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.go('/main/read'),
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Go to Books'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryViolet,
                side: const BorderSide(color: AppColors.primaryViolet),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _QuizCard({
    required this.quiz,
    required this.onTap,
    required this.onDelete,
  });

  Color get _subjectColor {
    switch (quiz.subject.toLowerCase()) {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: _subjectColor.withOpacity(0.2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _subjectColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.quiz_rounded,
                        color: _subjectColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.subject,
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _subjectColor,
                                    ),
                          ),
                          Text(
                            '${quiz.questions.length} Questions',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.softGrey,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    if (quiz.lastScore != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(quiz.lastScore!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${quiz.lastScore}/${quiz.questions.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(quiz.lastScore!),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 20,
                      color: AppColors.softGrey,
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  quiz.truncatedSourceText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.deepSlate.withOpacity(0.7),
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.softGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(quiz.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.softGrey,
                            fontSize: 11,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      'Start Quiz',
                      style: TextStyle(
                        color: _subjectColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: _subjectColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    final percentage = score / quiz.questions.length;
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _FlashcardSetCard extends StatelessWidget {
  final FlashcardSet flashcardSet;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FlashcardSetCard({
    required this.flashcardSet,
    required this.onTap,
    required this.onDelete,
  });

  Color get _subjectColor {
    switch (flashcardSet.subject.toLowerCase()) {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: _subjectColor.withOpacity(0.2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _subjectColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.style_rounded,
                        color: _subjectColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flashcardSet.subject,
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _subjectColor,
                                    ),
                          ),
                          Text(
                            '${flashcardSet.cards.length} Cards',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.softGrey,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 20,
                      color: AppColors.softGrey,
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  flashcardSet.truncatedSourceText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.deepSlate.withOpacity(0.7),
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.softGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(flashcardSet.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.softGrey,
                            fontSize: 11,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      'Review',
                      style: TextStyle(
                        color: _subjectColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: _subjectColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}


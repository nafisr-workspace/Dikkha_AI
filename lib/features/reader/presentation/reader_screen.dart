import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/core/providers/back_handler_provider.dart';
import 'package:dikkhaai/data/models/book.dart';
import 'package:dikkhaai/data/models/reading_state.dart';
import 'package:dikkhaai/data/services/storage_service.dart';
import 'package:dikkhaai/features/reader/data/book_repository.dart';
import 'package:dikkhaai/features/reader/presentation/widgets/markdown_reader.dart';
import 'package:dikkhaai/features/reader/presentation/widgets/text_selection_sheet.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  String? _selectedSubject;
  int _selectedChapterIndex = 0;
  List<String> _subjects = [];
  List<Chapter> _chapters = [];
  String _content = '';
  bool _isLoading = true;
  bool _showSubjectSelection = true;

  @override
  void initState() {
    super.initState();
    _loadUserSubjects();
  }

  void _loadUserSubjects() {
    final storage = ref.read(storageServiceProvider);
    final bookRepo = ref.read(bookRepositoryProvider);
    final user = storage.getCurrentUser();

    if (user != null) {
      _subjects = bookRepo.getSubjects(user.grade, user.group);
      
      // Always show subject selection (My Library) by default
      // Reading state is only used when user selects a subject
      setState(() {
        _isLoading = false;
        _showSubjectSelection = true;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadChapters() {
    if (_selectedSubject == null) return;

    final storage = ref.read(storageServiceProvider);
    final bookRepo = ref.read(bookRepositoryProvider);
    final user = storage.getCurrentUser();

    if (user != null) {
      _chapters = bookRepo.getChapters(user.grade, _selectedSubject!);
      
      if (_selectedChapterIndex >= _chapters.length) {
        _selectedChapterIndex = 0;
      }
      
      _loadContent();
    }
  }

  Future<void> _loadContent() async {
    if (_chapters.isEmpty) {
      setState(() {
        _content = '';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final bookRepo = ref.read(bookRepositoryProvider);
    final chapter = _chapters[_selectedChapterIndex];
    final content = await bookRepo.loadChapterContent(chapter.markdownPath);

    setState(() {
      _content = content;
      _isLoading = false;
    });

    // Save reading state
    _saveReadingState();
  }

  void _saveReadingState() {
    final storage = ref.read(storageServiceProvider);
    final currentState = storage.getReadingState();
    
    storage.saveReadingState(
      (currentState ?? ReadingState()).copyWith(
        lastSubject: _selectedSubject,
        lastChapterIndex: _selectedChapterIndex,
      ),
    );
  }

  void _onSubjectSelected(String subject) {
    // Check if there's a saved chapter for this subject
    final storage = ref.read(storageServiceProvider);
    final readingState = storage.getReadingState();
    
    int chapterIndex = 0;
    if (readingState?.lastSubject == subject && readingState?.lastChapterIndex != null) {
      chapterIndex = readingState!.lastChapterIndex!;
    }
    
    setState(() {
      _selectedSubject = subject;
      _selectedChapterIndex = chapterIndex;
      _showSubjectSelection = false;
    });
    _loadChapters();
  }

  void _onChapterSelected(int index) {
    if (_selectedChapterIndex != index) {
      setState(() {
        _selectedChapterIndex = index;
      });
      _loadContent();
    }
  }

  void _goBackToSubjects() {
    setState(() {
      _showSubjectSelection = true;
      _selectedSubject = null;
      _content = '';
    });
  }

  void _onTextSelected(String selectedText) {
    if (selectedText.trim().isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TextSelectionSheet(
        selectedText: selectedText,
        subject: _selectedSubject ?? '',
      ),
    );
  }

  _SubjectData _getSubjectData(String subject) {
    final subjectLower = subject.toLowerCase();
    
    if (subjectLower.contains('bangla') || subjectLower.contains('বাংলা')) {
      return _SubjectData(Icons.translate_rounded, const Color(0xFFE91E63));
    } else if (subjectLower.contains('english')) {
      return _SubjectData(Icons.abc_rounded, const Color(0xFF2196F3));
    } else if (subjectLower.contains('math') || subjectLower.contains('গণিত')) {
      return _SubjectData(Icons.calculate_rounded, const Color(0xFF4CAF50));
    } else if (subjectLower.contains('physics') || subjectLower.contains('পদার্থ')) {
      return _SubjectData(Icons.rocket_launch_rounded, const Color(0xFF9C27B0));
    } else if (subjectLower.contains('chemistry') || subjectLower.contains('রসায়ন')) {
      return _SubjectData(Icons.science_rounded, const Color(0xFFFF9800));
    } else if (subjectLower.contains('biology') || subjectLower.contains('জীববিজ্ঞান')) {
      return _SubjectData(Icons.biotech_rounded, const Color(0xFF00BCD4));
    } else if (subjectLower.contains('ict') || subjectLower.contains('কম্পিউটার')) {
      return _SubjectData(Icons.computer_rounded, const Color(0xFF607D8B));
    } else if (subjectLower.contains('higher math') || subjectLower.contains('উচ্চতর গণিত')) {
      return _SubjectData(Icons.functions_rounded, const Color(0xFF795548));
    } else if (subjectLower.contains('account') || subjectLower.contains('হিসাববিজ্ঞান')) {
      return _SubjectData(Icons.account_balance_rounded, const Color(0xFF3F51B5));
    } else if (subjectLower.contains('business') || subjectLower.contains('ব্যবসায়')) {
      return _SubjectData(Icons.business_center_rounded, const Color(0xFF009688));
    } else if (subjectLower.contains('finance') || subjectLower.contains('ব্যাংকিং')) {
      return _SubjectData(Icons.attach_money_rounded, const Color(0xFFCDDC39));
    } else if (subjectLower.contains('history') || subjectLower.contains('ইতিহাস')) {
      return _SubjectData(Icons.history_edu_rounded, const Color(0xFF8D6E63));
    } else if (subjectLower.contains('geography') || subjectLower.contains('ভূগোল')) {
      return _SubjectData(Icons.public_rounded, const Color(0xFF4DB6AC));
    } else if (subjectLower.contains('civics') || subjectLower.contains('পৌরনীতি')) {
      return _SubjectData(Icons.gavel_rounded, const Color(0xFFFFB74D));
    } else if (subjectLower.contains('economics') || subjectLower.contains('অর্থনীতি')) {
      return _SubjectData(Icons.trending_up_rounded, const Color(0xFF7E57C2));
    }
    
    return _SubjectData(Icons.menu_book_rounded, AppColors.primaryViolet);
  }

  void _updateBackHandler() {
    final backHandler = ref.read(backHandlerProvider.notifier);
    
    if (!_showSubjectSelection && _selectedSubject != null) {
      // In reading mode - register back handler to go back to subjects
      backHandler.setHandler(() {
        _goBackToSubjects();
        return true; // Back was handled
      });
    } else {
      // In subject selection - clear handler (use default app behavior)
      backHandler.clearHandler();
    }
  }

  @override
  void dispose() {
    // Clear back handler when screen is disposed
    ref.read(backHandlerProvider.notifier).clearHandler();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update back handler based on current state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBackHandler();
    });

    if (_subjects.isEmpty && !_isLoading) {
      return _buildNoSubjectsState();
    }

    // Show subject selection screen
    if (_showSubjectSelection) {
      return _buildSubjectSelectionScreen();
    }

    // Show reading screen
    return _buildReadingScreen();
  }

  Widget _buildNoSubjectsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.lavenderMist,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                size: 40,
                color: AppColors.primaryViolet,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Subjects Available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please update your profile to see subjects for your grade and group.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.softGrey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSelectionScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.creamyWhite,
            AppColors.lavenderMist.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📚 My Library',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepSlate,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a subject to start reading',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.softGrey,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Subject cards grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                return _ModernSubjectCard(
                  subject: subject,
                  index: index,
                  onTap: () => _onSubjectSelected(subject),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingScreen() {
    final subjectData = _getSubjectData(_selectedSubject!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Back button
              Material(
                color: AppColors.lavenderMist.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _goBackToSubjects,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.arrow_back_rounded, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Subject icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: subjectData.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  subjectData.icon,
                  color: subjectData.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Subject info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedSubject!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (_chapters.isNotEmpty)
                      Text(
                        'Ch. ${_selectedChapterIndex + 1}: ${_chapters[_selectedChapterIndex].title}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.softGrey,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Chapters button
              Material(
                color: subjectData.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _showChaptersSheet(),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.list_rounded, size: 18, color: subjectData.color),
                        const SizedBox(width: 6),
                        Text(
                          'Chapters',
                          style: TextStyle(
                            color: subjectData.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryViolet,
                  ),
                )
              : _content.isEmpty
                  ? _buildNoContentState()
                  : MarkdownReader(
                      content: _content,
                      onTextSelected: _onTextSelected,
                    ),
        ),
      ],
    );
  }

  Widget _buildNoContentState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: AppColors.softGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'Content Coming Soon',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'This chapter is being prepared. Please check back later.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.softGrey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChaptersSheet() {
    final subjectData = _getSubjectData(_selectedSubject!);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Column(
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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: subjectData.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.format_list_numbered_rounded,
                        color: subjectData.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chapters',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${_chapters.length} chapters available',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.softGrey,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: AppColors.lavenderMist.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.close_rounded, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: AppColors.paleGrey.withValues(alpha: 0.5), height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = _chapters[index];
                    final isSelected = index == _selectedChapterIndex;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: isSelected 
                            ? subjectData.color.withValues(alpha: 0.1) 
                            : AppColors.creamyWhite,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _onChapterSelected(index);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? subjectData.color.withValues(alpha: 0.3)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? subjectData.color
                                        : AppColors.lavenderMist,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${chapter.number}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : subjectData.color,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    chapter.title,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      fontSize: 15,
                                      color: isSelected
                                          ? subjectData.color
                                          : AppColors.deepSlate,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: subjectData.color,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modern subject card widget with icons
class _ModernSubjectCard extends StatelessWidget {
  final String subject;
  final int index;
  final VoidCallback onTap;

  const _ModernSubjectCard({
    required this.subject,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subjectData = _getSubjectData(subject);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                subjectData.color.withValues(alpha: 0.15),
                subjectData.color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: subjectData.color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: subjectData.color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: subjectData.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon container
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: subjectData.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        subjectData.icon,
                        color: subjectData.color,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    // Subject name
                    Text(
                      subject,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepSlate,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Continue button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: subjectData.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  _SubjectData _getSubjectData(String subject) {
    final subjectLower = subject.toLowerCase();
    
    if (subjectLower.contains('bangla') || subjectLower.contains('বাংলা')) {
      return _SubjectData(Icons.translate_rounded, const Color(0xFFE91E63));
    } else if (subjectLower.contains('english')) {
      return _SubjectData(Icons.abc_rounded, const Color(0xFF2196F3));
    } else if (subjectLower.contains('math') || subjectLower.contains('গণিত')) {
      return _SubjectData(Icons.calculate_rounded, const Color(0xFF4CAF50));
    } else if (subjectLower.contains('physics') || subjectLower.contains('পদার্থ')) {
      return _SubjectData(Icons.rocket_launch_rounded, const Color(0xFF9C27B0));
    } else if (subjectLower.contains('chemistry') || subjectLower.contains('রসায়ন')) {
      return _SubjectData(Icons.science_rounded, const Color(0xFFFF9800));
    } else if (subjectLower.contains('biology') || subjectLower.contains('জীববিজ্ঞান')) {
      return _SubjectData(Icons.biotech_rounded, const Color(0xFF00BCD4));
    } else if (subjectLower.contains('ict') || subjectLower.contains('কম্পিউটার')) {
      return _SubjectData(Icons.computer_rounded, const Color(0xFF607D8B));
    } else if (subjectLower.contains('higher math') || subjectLower.contains('উচ্চতর গণিত')) {
      return _SubjectData(Icons.functions_rounded, const Color(0xFF795548));
    } else if (subjectLower.contains('account') || subjectLower.contains('হিসাববিজ্ঞান')) {
      return _SubjectData(Icons.account_balance_rounded, const Color(0xFF3F51B5));
    } else if (subjectLower.contains('business') || subjectLower.contains('ব্যবসায়')) {
      return _SubjectData(Icons.business_center_rounded, const Color(0xFF009688));
    } else if (subjectLower.contains('finance') || subjectLower.contains('ব্যাংকিং')) {
      return _SubjectData(Icons.attach_money_rounded, const Color(0xFFCDDC39));
    } else if (subjectLower.contains('history') || subjectLower.contains('ইতিহাস')) {
      return _SubjectData(Icons.history_edu_rounded, const Color(0xFF8D6E63));
    } else if (subjectLower.contains('geography') || subjectLower.contains('ভূগোল')) {
      return _SubjectData(Icons.public_rounded, const Color(0xFF4DB6AC));
    } else if (subjectLower.contains('civics') || subjectLower.contains('পৌরনীতি')) {
      return _SubjectData(Icons.gavel_rounded, const Color(0xFFFFB74D));
    } else if (subjectLower.contains('economics') || subjectLower.contains('অর্থনীতি')) {
      return _SubjectData(Icons.trending_up_rounded, const Color(0xFF7E57C2));
    }
    
    // Default
    return _SubjectData(Icons.menu_book_rounded, AppColors.primaryViolet);
  }
}

class _SubjectData {
  final IconData icon;
  final Color color;

  _SubjectData(this.icon, this.color);
}

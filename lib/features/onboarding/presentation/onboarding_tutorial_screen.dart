import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/app/router.dart';

class OnboardingTutorialScreen extends StatefulWidget {
  const OnboardingTutorialScreen({super.key});

  @override
  State<OnboardingTutorialScreen> createState() => _OnboardingTutorialScreenState();
}

class _OnboardingTutorialScreenState extends State<OnboardingTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_TutorialStep> _steps = [
    _TutorialStep(
      icon: Icons.menu_book_rounded,
      iconColor: const Color(0xFF6366F1),
      title: 'Read Your Textbooks',
      description: 'Access your Class 9-10 NCTB textbooks in a clean, easy-to-read format with chapter navigation.',
      tip: 'Tap on any subject from "My Library" to start reading!',
    ),
    _TutorialStep(
      icon: Icons.touch_app_rounded,
      iconColor: const Color(0xFF10B981),
      title: 'Select Text for Help',
      description: 'Long press and select any text while reading. A menu will appear with AI-powered options.',
      tip: 'Try selecting a difficult paragraph or equation!',
    ),
    _TutorialStep(
      icon: Icons.quiz_rounded,
      iconColor: const Color(0xFFF59E0B),
      title: 'Create Quizzes & Flashcards',
      description: 'Generate instant quizzes and flashcards from selected text to test your knowledge.',
      tip: 'Great for exam preparation!',
    ),
    _TutorialStep(
      icon: Icons.chat_bubble_rounded,
      iconColor: const Color(0xFF8B5CF6),
      title: 'Ask AI Anything',
      description: 'Use the AI Chat to ask questions about any subject. Get explanations, solutions, and examples.',
      tip: 'AI understands both Bangla and English!',
    ),
    _TutorialStep(
      icon: Icons.school_rounded,
      iconColor: const Color(0xFFEF4444),
      title: 'Review in Materials Tab',
      description: 'All your created quizzes and flashcards are saved in the Materials tab for later review.',
      tip: 'Practice regularly for better results!',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Completed onboarding, go to main screen
      context.go('${AppRoutes.main}/read');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
              AppColors.primaryViolet.withOpacity(0.1),
              AppColors.creamyWhite,
              AppColors.lavenderMist.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryViolet.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lightbulb_rounded,
                            size: 16,
                            color: AppColors.primaryViolet,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Quick Tutorial',
                            style: TextStyle(
                              color: AppColors.primaryViolet,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Step indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        '${_currentPage + 1} / ${_steps.length}',
                        style: TextStyle(
                          color: AppColors.deepSlate,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return _buildTutorialPage(_steps[index]);
                  },
                ),
              ),
              // Progress indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _steps.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == _currentPage ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? _steps[index].iconColor
                            : AppColors.paleGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Next button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _nextPage,
                    style: FilledButton.styleFrom(
                      backgroundColor: _steps[_currentPage].iconColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage < _steps.length - 1
                              ? 'Next'
                              : 'Start Learning',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage < _steps.length - 1
                              ? Icons.arrow_forward_rounded
                              : Icons.rocket_launch_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialPage(_TutorialStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animated background
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        step.iconColor.withOpacity(0.3),
                        step.iconColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                // Icon container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: step.iconColor.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    step.icon,
                    size: 56,
                    color: step.iconColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepSlate,
                ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.softGrey,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24),
          // Tip box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: step.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: step.iconColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: step.iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.tips_and_updates_rounded,
                    size: 20,
                    color: step.iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.tip,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: step.iconColor.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
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

class _TutorialStep {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String tip;

  _TutorialStep({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.tip,
  });
}


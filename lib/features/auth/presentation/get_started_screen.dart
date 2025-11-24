import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/app/router.dart';
import 'package:dikkhaai/core/widgets/primary_button.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryViolet,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo placeholder
              FadeTransition(
                opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: AppColors.pureWhite,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'দ',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryViolet,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Dikkha AI',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pureWhite,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Learn Faster, Go Further.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.pureWhite.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
              const Spacer(flex: 3),
              // Get Started Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: SecondaryButton(
                  text: 'Get Started',
                  onPressed: () => context.go(AppRoutes.phone),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/app/router.dart';
import 'package:dikkhaai/core/constants/app_constants.dart';
import 'package:dikkhaai/data/services/storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    final storage = ref.read(storageServiceProvider);
    final currentUser = storage.getCurrentUser();

    if (currentUser != null) {
      // User exists, go to main screen (Read Book tab)
      context.go('${AppRoutes.main}/read');
    } else {
      // No user, go to get started
      context.go(AppRoutes.getStarted);
    }
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Text(
            AppConstants.appTagline,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}


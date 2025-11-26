import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dikkhaai/app/router.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/core/providers/back_handler_provider.dart';

class DikkhaApp extends ConsumerStatefulWidget {
  const DikkhaApp({super.key});

  @override
  ConsumerState<DikkhaApp> createState() => _DikkhaAppState();
}

class _DikkhaAppState extends ConsumerState<DikkhaApp> {
  bool _isShowingExitDialog = false;

  Future<bool> _onWillPop(BuildContext dialogContext) async {
    // First check if any screen has a custom back handler
    final backHandler = ref.read(backHandlerProvider.notifier);
    if (backHandler.handleBack()) {
      return false; // Back was handled by the screen
    }

    // Prevent multiple dialogs
    if (_isShowingExitDialog) return false;

    // Show exit confirmation dialog
    _isShowingExitDialog = true;
    final shouldExit = await _showExitConfirmationDialog(dialogContext);
    _isShowingExitDialog = false;
    
    return shouldExit;
  }

  Future<bool> _showExitConfirmationDialog(BuildContext dialogContext) async {
    final result = await showDialog<bool>(
      context: dialogContext,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.lavenderMist,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.exit_to_app_rounded,
                color: AppColors.primaryViolet,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Exit App?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to exit Dikkha AI?',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.softGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.softGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryViolet,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Exit',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Dikkha AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _onWillPop(context);
            if (shouldPop) {
              SystemNavigator.pop(); // Actually exit the app
            }
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

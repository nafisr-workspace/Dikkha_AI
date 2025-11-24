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
  DateTime? _lastBackPressTime;

  Future<bool> _onWillPop() async {
    // First check if any screen has a custom back handler
    final backHandler = ref.read(backHandlerProvider.notifier);
    if (backHandler.handleBack()) {
      return false; // Back was handled by the screen
    }

    // Default behavior: double-tap to exit
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.deepSlate,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          SystemNavigator.pop(); // Actually exit the app
        }
      },
      child: MaterialApp.router(
        title: 'Dikkha AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}

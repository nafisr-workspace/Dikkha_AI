import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to handle back button behavior across the app
/// When a screen sets a custom back handler, it will be called instead of default back behavior

typedef BackHandler = bool Function();

class BackHandlerNotifier extends StateNotifier<BackHandler?> {
  BackHandlerNotifier() : super(null);

  void setHandler(BackHandler? handler) {
    state = handler;
  }

  void clearHandler() {
    state = null;
  }

  /// Returns true if back was handled, false if default behavior should occur
  bool handleBack() {
    if (state != null) {
      return state!();
    }
    return false;
  }
}

final backHandlerProvider = StateNotifierProvider<BackHandlerNotifier, BackHandler?>((ref) {
  return BackHandlerNotifier();
});


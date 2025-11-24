import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:dikkhaai/data/models/chat_session.dart';
import 'package:dikkhaai/data/models/chat_message.dart';
import 'package:dikkhaai/data/services/storage_service.dart';
import 'package:dikkhaai/data/services/ai_service.dart';

// Pending message from text selection
class PendingChatMessage {
  final String message;
  final String subject;
  final String? selectedText;
  final String? imagePath;

  PendingChatMessage({
    required this.message,
    required this.subject,
    this.selectedText,
    this.imagePath,
  });
}

final pendingChatMessageProvider = StateProvider<PendingChatMessage?>((ref) => null);

// Current chat session
final currentChatSessionProvider = StateProvider<ChatSession?>((ref) => null);

// Current subject for chat
final currentChatSubjectProvider = StateProvider<String?>((ref) => null);

// Messages for current session
final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier(ref);
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;

  ChatMessagesNotifier(this._ref) : super([]);

  void loadMessages(String sessionId) {
    final storage = _ref.read(storageServiceProvider);
    state = storage.getMessagesForSession(sessionId);
  }

  void clearMessages() {
    state = [];
  }

  Future<void> sendMessage({
    required String content,
    required String subject,
    String? imagePath,
    String? selectedText,
  }) async {
    final storage = _ref.read(storageServiceProvider);
    final aiService = _ref.read(aiServiceProvider);
    final currentSession = _ref.read(currentChatSessionProvider);
    final user = storage.getCurrentUser();

    if (user == null) return;

    // Create or get session
    ChatSession session;
    if (currentSession == null) {
      session = ChatSession(
        id: const Uuid().v4(),
        userId: user.id,
        subject: subject,
        title: content.length > 50 ? '${content.substring(0, 50)}...' : content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await storage.saveChatSession(session);
      _ref.read(currentChatSessionProvider.notifier).state = session;
    } else {
      session = currentSession.copyWith(updatedAt: DateTime.now());
      await storage.saveChatSession(session);
    }

    // Create user message
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      sessionId: session.id,
      role: 'user',
      content: content,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );

    await storage.saveChatMessage(userMessage);
    state = [...state, userMessage];

    // Get AI response
    try {
      final response = await aiService.getResponse(
        message: content,
        subject: subject,
        selectedText: selectedText,
        imagePath: imagePath,
      );

      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        sessionId: session.id,
        role: 'ai',
        content: response,
        createdAt: DateTime.now(),
      );

      await storage.saveChatMessage(aiMessage);
      state = [...state, aiMessage];
    } catch (e) {
      // Add error message
      final errorMessage = ChatMessage(
        id: const Uuid().v4(),
        sessionId: session.id,
        role: 'ai',
        content: 'দুঃখিত, একটি সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।\n\n(Sorry, something went wrong. Please try again.)',
        createdAt: DateTime.now(),
      );

      await storage.saveChatMessage(errorMessage);
      state = [...state, errorMessage];
    }
  }

  void startNewChat() {
    _ref.read(currentChatSessionProvider.notifier).state = null;
    state = [];
  }
}

// Chat sessions list
final chatSessionsProvider = Provider<List<ChatSession>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getAllChatSessions();
});

// Is sending message
final isSendingMessageProvider = StateProvider<bool>((ref) => false);


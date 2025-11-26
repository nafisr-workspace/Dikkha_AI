import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dikkhaai/data/models/user.dart';
import 'package:dikkhaai/data/models/chat_session.dart';
import 'package:dikkhaai/data/models/chat_message.dart';
import 'package:dikkhaai/data/models/reading_state.dart';
import 'package:dikkhaai/data/models/quiz.dart';
import 'package:dikkhaai/data/models/flashcard.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  // User operations
  Box<User> get _userBox => Hive.box<User>('users');

  Future<void> saveUser(User user) async {
    await _userBox.put('current_user', user);
  }

  User? getCurrentUser() {
    return _userBox.get('current_user');
  }

  Future<void> deleteCurrentUser() async {
    await _userBox.delete('current_user');
  }

  // Chat Session operations
  Box<ChatSession> get _sessionBox => Hive.box<ChatSession>('chat_sessions');

  Future<void> saveChatSession(ChatSession session) async {
    await _sessionBox.put(session.id, session);
  }

  List<ChatSession> getAllChatSessions() {
    return _sessionBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  ChatSession? getChatSession(String id) {
    return _sessionBox.get(id);
  }

  Future<void> deleteChatSession(String id) async {
    await _sessionBox.delete(id);
    // Also delete all messages in this session
    final messageBox = Hive.box<ChatMessage>('chat_messages');
    final messagesToDelete = messageBox.values
        .where((msg) => msg.sessionId == id)
        .map((msg) => msg.id)
        .toList();
    for (final msgId in messagesToDelete) {
      await messageBox.delete(msgId);
    }
  }

  Future<void> clearAllChatSessions() async {
    await _sessionBox.clear();
    await Hive.box<ChatMessage>('chat_messages').clear();
  }

  // Chat Message operations
  Box<ChatMessage> get _messageBox => Hive.box<ChatMessage>('chat_messages');

  Future<void> saveChatMessage(ChatMessage message) async {
    await _messageBox.put(message.id, message);
  }

  List<ChatMessage> getMessagesForSession(String sessionId) {
    return _messageBox.values
        .where((msg) => msg.sessionId == sessionId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // Reading State operations
  Box<ReadingState> get _readingStateBox => Hive.box<ReadingState>('reading_state');

  Future<void> saveReadingState(ReadingState state) async {
    await _readingStateBox.put('current', state);
  }

  ReadingState? getReadingState() {
    return _readingStateBox.get('current');
  }

  // Quiz operations
  Box<Quiz> get _quizBox => Hive.box<Quiz>('quizzes');

  Future<void> saveQuiz(Quiz quiz) async {
    await _quizBox.put(quiz.id, quiz);
  }

  List<Quiz> getAllQuizzes() {
    return _quizBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Quiz> getQuizzesBySubject(String subject) {
    return _quizBox.values
        .where((quiz) => quiz.subject == subject)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Quiz? getQuiz(String id) {
    return _quizBox.get(id);
  }

  Future<void> deleteQuiz(String id) async {
    await _quizBox.delete(id);
  }

  Future<void> clearAllQuizzes() async {
    await _quizBox.clear();
  }

  // Flashcard operations
  Box<FlashcardSet> get _flashcardBox => Hive.box<FlashcardSet>('flashcards');

  Future<void> saveFlashcardSet(FlashcardSet flashcardSet) async {
    await _flashcardBox.put(flashcardSet.id, flashcardSet);
  }

  List<FlashcardSet> getAllFlashcardSets() {
    return _flashcardBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<FlashcardSet> getFlashcardSetsBySubject(String subject) {
    return _flashcardBox.values
        .where((set) => set.subject == subject)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  FlashcardSet? getFlashcardSet(String id) {
    return _flashcardBox.get(id);
  }

  Future<void> deleteFlashcardSet(String id) async {
    await _flashcardBox.delete(id);
  }

  Future<void> clearAllFlashcardSets() async {
    await _flashcardBox.clear();
  }

  // Clear all data (for logout)
  Future<void> clearAllData() async {
    await _userBox.clear();
    await _sessionBox.clear();
    await _messageBox.clear();
    await _readingStateBox.clear();
    await _quizBox.clear();
    await _flashcardBox.clear();
  }
}


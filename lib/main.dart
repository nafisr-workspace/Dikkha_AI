import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dikkhaai/app/app.dart';
import 'package:dikkhaai/data/models/user.dart';
import 'package:dikkhaai/data/models/chat_session.dart';
import 'package:dikkhaai/data/models/chat_message.dart';
import 'package:dikkhaai/data/models/reading_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ChatSessionAdapter());
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(ReadingStateAdapter());

  // Open Hive boxes
  await Hive.openBox<User>('users');
  await Hive.openBox<ChatSession>('chat_sessions');
  await Hive.openBox<ChatMessage>('chat_messages');
  await Hive.openBox<ReadingState>('reading_state');

  runApp(
    const ProviderScope(
      child: DikkhaApp(),
    ),
  );
}

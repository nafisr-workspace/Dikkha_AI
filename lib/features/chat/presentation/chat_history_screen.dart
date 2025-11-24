import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/app/router.dart';
import 'package:dikkhaai/data/models/chat_session.dart';
import 'package:dikkhaai/data/services/storage_service.dart';
import 'package:dikkhaai/features/chat/providers/chat_provider.dart';

class ChatHistoryScreen extends ConsumerStatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  ConsumerState<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends ConsumerState<ChatHistoryScreen> {
  List<ChatSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    final storage = ref.read(storageServiceProvider);
    setState(() {
      _sessions = storage.getAllChatSessions();
    });
  }

  void _deleteSession(ChatSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final storage = ref.read(storageServiceProvider);
              await storage.deleteChatSession(session.id);
              _loadSessions();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conversation deleted'),
                    backgroundColor: AppColors.primaryViolet,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text('Are you sure you want to delete all conversations? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final storage = ref.read(storageServiceProvider);
              await storage.clearAllChatSessions();
              _loadSessions();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All conversations deleted'),
                    backgroundColor: AppColors.primaryViolet,
                  ),
                );
              }
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _openSession(ChatSession session) {
    // Set the current session and navigate to chat
    ref.read(currentChatSessionProvider.notifier).state = session;
    ref.read(currentChatSubjectProvider.notifier).state = session.subject;
    ref.read(chatMessagesProvider.notifier).loadMessages(session.id);
    
    context.go('${AppRoutes.main}/chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Chat History'),
        actions: [
          if (_sessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllHistory,
              tooltip: 'Clear all history',
            ),
        ],
      ),
      body: _sessions.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _sessions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final session = _sessions[index];
                return _ChatHistoryItem(
                  session: session,
                  onTap: () => _openSession(session),
                  onDelete: () => _deleteSession(session),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lavenderMist,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                size: 40,
                color: AppColors.primaryViolet,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No conversations yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your chat history will appear here',
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
}

class _ChatHistoryItem extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ChatHistoryItem({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Subject icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lavenderMist,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    session.subject.isNotEmpty
                        ? session.subject[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryViolet,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Session info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.subject,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.title ?? 'Conversation',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.softGrey,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(session.updatedAt)} at ${timeFormat.format(session.updatedAt)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.softGrey,
                          ),
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: AppColors.softGrey,
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}


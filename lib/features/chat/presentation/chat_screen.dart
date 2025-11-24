import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dikkhaai/app/router.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/core/constants/app_constants.dart';
import 'package:dikkhaai/data/services/storage_service.dart';
import 'package:dikkhaai/features/chat/providers/chat_provider.dart';
import 'package:dikkhaai/features/chat/presentation/widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();
  List<String> _subjects = [];
  String? _selectedSubject;
  File? _attachedImage;
  bool _isSending = false;
  bool _isInitialized = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initializeScreen() {
    if (_isInitialized) return;
    _isInitialized = true;
    
    _loadSubjects();
    _checkPendingMessage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _loadSubjects() {
    final storage = ref.read(storageServiceProvider);
    final user = storage.getCurrentUser();

    if (user != null) {
      final subjects = AppConstants.subjectsByGroup[user.group] ?? 
                  AppConstants.subjectsByGroup['Other']!;
      
      final currentSubject = ref.read(currentChatSubjectProvider);
      String? selected;
      
      if (currentSubject != null && subjects.contains(currentSubject)) {
        selected = currentSubject;
      } else if (subjects.isNotEmpty) {
        selected = subjects.first;
        Future.microtask(() {
          if (mounted) {
            ref.read(currentChatSubjectProvider.notifier).state = selected;
          }
        });
      }
      
      setState(() {
        _subjects = subjects;
        _selectedSubject = selected;
      });
    }
  }

  void _checkPendingMessage() {
    final pending = ref.read(pendingChatMessageProvider);
    if (pending != null) {
      if (_subjects.contains(pending.subject)) {
        setState(() {
          _selectedSubject = pending.subject;
        });
        Future.microtask(() {
          if (mounted) {
            ref.read(currentChatSubjectProvider.notifier).state = pending.subject;
          }
        });
      }
      
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _sendMessage(pending.message, selectedText: pending.selectedText);
        }
      });
      
      Future.microtask(() {
        if (mounted) {
          ref.read(pendingChatMessageProvider.notifier).state = null;
        }
      });
    }
  }

  void _onSubjectSelected(String? subject) {
    if (subject != null && _selectedSubject != subject) {
      setState(() {
        _selectedSubject = subject;
      });
      Future.microtask(() {
        if (mounted) {
          ref.read(currentChatSubjectProvider.notifier).state = subject;
          ref.read(chatMessagesProvider.notifier).startNewChat();
        }
      });
    }
  }

  Future<void> _sendMessage(String message, {String? selectedText}) async {
    if (message.trim().isEmpty || _selectedSubject == null) return;

    setState(() {
      _isSending = true;
    });

    _inputController.clear();
    _inputFocusNode.unfocus();

    await ref.read(chatMessagesProvider.notifier).sendMessage(
      content: message,
      subject: _selectedSubject!,
      imagePath: _attachedImage?.path,
      selectedText: selectedText,
    );

    if (mounted) {
      setState(() {
        _attachedImage = null;
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _attachedImage = File(pickedFile.path);
      });
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.paleGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _buildImageOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.lavenderMist,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryViolet, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _attachedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.creamyWhite,
            AppColors.lavenderMist.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Column(
        children: [
          // Modern header
          _buildHeader(),
          // Messages area
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : _buildMessagesList(messages),
          ),
          // Image preview
          if (_attachedImage != null) _buildImagePreview(),
          // Modern input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Subject dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.lavenderMist.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSubject,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryViolet),
                  hint: const Text('Select Subject'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepSlate,
                      ),
                  items: _subjects.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getSubjectColor(subject),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(subject),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _onSubjectSelected,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // New chat button
          _buildHeaderButton(
            icon: Icons.add_comment_rounded,
            tooltip: 'New Chat',
            onTap: () {
              ref.read(chatMessagesProvider.notifier).startNewChat();
            },
          ),
          const SizedBox(width: 8),
          // History button
          _buildHeaderButton(
            icon: Icons.history_rounded,
            tooltip: 'Chat History',
            onTap: () => context.push(AppRoutes.chatHistory),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.lavenderMist.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AppColors.primaryViolet, size: 22),
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFF38181),
      const Color(0xFFAA96DA),
      const Color(0xFFFCBAD3),
    ];
    return colors[subject.hashCode % colors.length];
  }

  Widget _buildMessagesList(List messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: messages.length + (_isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isSending && index == messages.length) {
          return _buildTypingIndicator();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MessageBubble(message: messages[index]),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
                const SizedBox(width: 12),
                Text(
                  'AI is thinking',
                  style: TextStyle(
                    color: AppColors.softGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final delay = index * 0.2;
        final value = (_pulseController.value + delay) % 1.0;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primaryViolet.withValues(alpha: 0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _attachedImage!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _removeImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _onVoiceInput() {
    // TODO: Integrate voice input in future
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.mic, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Voice input coming soon!'),
          ],
        ),
        backgroundColor: AppColors.primaryViolet,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            _buildInputButton(
              icon: Icons.add_rounded,
              onTap: _showImagePicker,
              enabled: !_isSending,
            ),
            const SizedBox(width: 6),
            // Voice input button
            _buildInputButton(
              icon: Icons.mic_rounded,
              onTap: _onVoiceInput,
              enabled: !_isSending,
            ),
            const SizedBox(width: 8),
            // Text input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.creamyWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.lavenderMist,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _inputController,
                  focusNode: _inputFocusNode,
                  enabled: !_isSending && _selectedSubject != null,
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: _selectedSubject != null 
                        ? 'Ask about $_selectedSubject...'
                        : 'Select a subject first...',
                    hintStyle: TextStyle(
                      color: AppColors.softGrey.withValues(alpha: 0.7),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(_inputController.text),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: _inputController.text.trim().isNotEmpty || _isSending
                    ? AppColors.primaryViolet
                    : AppColors.primaryViolet.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: !_isSending && _selectedSubject != null
                      ? () => _sendMessage(_inputController.text)
                      : null,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Material(
      color: enabled ? AppColors.lavenderMist : AppColors.paleGrey.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: enabled ? AppColors.primaryViolet : AppColors.softGrey,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated AI icon
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.05),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryViolet,
                          AppColors.primaryViolet.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryViolet.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Hello! I\'m your AI tutor',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepSlate,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedSubject != null
                  ? 'Ask me anything about $_selectedSubject!\nI\'m here to help you learn and succeed.'
                  : 'Select a subject above to start our learning journey together.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.softGrey,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 32),
            // Quick prompts
            if (_selectedSubject != null) ...[
              Text(
                'Try asking:',
                style: TextStyle(
                  color: AppColors.softGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickPrompt('Explain the basics'),
                  _buildQuickPrompt('Give me an example'),
                  _buildQuickPrompt('Help me practice'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPrompt(String text) {
    return GestureDetector(
      onTap: () {
        _inputController.text = text;
        _sendMessage(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lavenderMist, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.primaryViolet,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

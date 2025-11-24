import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dikkhaai/app/router.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/data/services/storage_service.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        context.go('${AppRoutes.main}/read');
        break;
      case 1:
        context.go('${AppRoutes.main}/chat');
        break;
    }
  }

  void _showAvatarMenu() {
    final storage = ref.read(storageServiceProvider);
    final user = storage.getCurrentUser();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _buildAvatar(user, 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          'Class ${user?.grade ?? ''} • ${user?.group ?? ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.softGrey,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              // Profile option with Pro badge
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Row(
                  children: [
                    const Text('Profile'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.profile);
                },
              ),
              // Chat History option
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Chat History'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.chatHistory);
                },
              ),
              // Logout option
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(dynamic user, double radius) {
    final hasProfilePic = user?.profilePicPath != null && 
        File(user!.profilePicPath!).existsSync();
    
    if (hasProfilePic) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(user!.profilePicPath!)),
      );
    }
    
    // Default avatar when no profile picture
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.lavenderMist,
      child: Icon(
        Icons.person_rounded,
        size: radius * 1.2,
        color: AppColors.primaryViolet,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final storage = ref.read(storageServiceProvider);
              await storage.clearAllData();
              if (mounted) {
                context.go(AppRoutes.getStarted);
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);
    final user = storage.getCurrentUser();

    // Update selected index based on current route
    final location = GoRouterState.of(context).uri.path;
    if (location.contains('/chat') && _selectedIndex != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _selectedIndex = 1);
      });
    } else if (location.contains('/read') && _selectedIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _selectedIndex = 0);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dikkha AI'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _showAvatarMenu,
              child: _buildAvatar(user, 18),
            ),
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Read Book',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'AI Chat',
          ),
        ],
      ),
    );
  }
}


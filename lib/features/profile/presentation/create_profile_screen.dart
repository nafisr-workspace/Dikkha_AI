import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:dikkhaai/app/router.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/core/constants/app_constants.dart';
import 'package:dikkhaai/core/widgets/primary_button.dart';
import 'package:dikkhaai/core/widgets/app_text_field.dart';
import 'package:dikkhaai/core/widgets/app_dropdown.dart';
import 'package:dikkhaai/data/models/user.dart';
import 'package:dikkhaai/data/services/storage_service.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const CreateProfileScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedGrade;
  String? _selectedGroup;
  String? _selectedBoard;
  bool _isLoading = false;
  String? _profilePicPath;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _selectedGrade != null &&
        _selectedGroup != null &&
        _selectedBoard != null;
  }

  Future<void> _pickProfilePicture() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
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
            Text(
              'Choose Profile Photo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: AppColors.primaryViolet,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildPickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_profilePicPath != null)
                  _buildPickerOption(
                    icon: Icons.delete_rounded,
                    label: 'Remove',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _profilePicPath = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required Color color,
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
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        // Save to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedPath = '${appDir.path}/$fileName';
        
        await File(pickedFile.path).copy(savedPath);
        
        setState(() {
          _profilePicPath = savedPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createProfile() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storage = ref.read(storageServiceProvider);
      
      final user = User(
        id: const Uuid().v4(),
        phone: widget.phoneNumber,
        name: _nameController.text.trim(),
        grade: _selectedGrade!.replaceAll('Class ', ''),
        group: _selectedGroup!,
        board: _selectedBoard!,
        createdAt: DateTime.now(),
        profilePicPath: _profilePicPath,
      );

      await storage.saveUser(user);

      if (mounted) {
        // Navigate to onboarding tutorial for new users
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatPhoneNumber(String phone) {
    // Format: +880 1711-051800
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+880') && cleaned.length >= 14) {
      return '+880 ${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final formattedPhone = _formatPhoneNumber(widget.phoneNumber);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Create your account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete your profile to continue',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.softGrey,
                      ),
                ),
                const SizedBox(height: 32),
                // Profile Picture
                Center(
                  child: GestureDetector(
                    onTap: _pickProfilePicture,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.lavenderMist,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryViolet.withValues(alpha: 0.3),
                              width: 3,
                            ),
                            image: _profilePicPath != null
                                ? DecorationImage(
                                    image: FileImage(File(_profilePicPath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _profilePicPath == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 50,
                                  color: AppColors.primaryViolet,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryViolet,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.pureWhite,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.pureWhite,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Add Profile Photo',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryViolet,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                // Phone number display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.lavenderMist.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryViolet.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryViolet.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.phone_rounded,
                          color: AppColors.primaryViolet,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone Number',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.softGrey,
                                ),
                          ),
                          Text(
                            formattedPhone,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.deepSlate,
                                ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF4CAF50),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Name field
                Text(
                  'Name',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _nameController,
                  hintText: 'Enter your name',
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                // Grade dropdown
                Text(
                  'Grade',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                AppDropdown<String>(
                  value: _selectedGrade,
                  items: AppConstants.grades,
                  hintText: 'Select your grade',
                  onChanged: (value) {
                    setState(() {
                      _selectedGrade = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Group dropdown
                Text(
                  'Group',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                AppDropdown<String>(
                  value: _selectedGroup,
                  items: AppConstants.groups,
                  hintText: 'Select your group',
                  onChanged: (value) {
                    setState(() {
                      _selectedGroup = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Board dropdown
                Text(
                  'Board',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                AppDropdown<String>(
                  value: _selectedBoard,
                  items: AppConstants.boards,
                  hintText: 'Select your board',
                  onChanged: (value) {
                    setState(() {
                      _selectedBoard = value;
                    });
                  },
                ),
                const SizedBox(height: 48),
                // Create button
                PrimaryButton(
                  text: 'Create an Account',
                  onPressed: _isFormValid ? _createProfile : null,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


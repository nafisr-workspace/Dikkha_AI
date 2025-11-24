import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dikkhaai/app/router.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/core/widgets/primary_button.dart';
import 'package:dikkhaai/data/services/storage_service.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    setState(() {
      _errorText = null;
    });
  }

  // Get only digits from input
  String get _digitsOnly {
    return _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
  }

  // Check if we have exactly 10 digits
  bool get _isValidPhone {
    return _digitsOnly.length == 10;
  }

  Future<void> _continueWithPhone() async {
    if (!_isValidPhone) {
      setState(() {
        _errorText = 'Please enter exactly 10 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final storage = ref.read(storageServiceProvider);
      
      // Format: +880 + 10 digits = full phone number
      final formattedPhone = '+880$_digitsOnly';

      // Simulate a brief delay for UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Check if user already exists with this phone number
      final existingUser = storage.getCurrentUser();

      if (existingUser != null && existingUser.phone == formattedPhone) {
        // Existing user - go directly to main screen
        context.go('${AppRoutes.main}/read');
      } else {
        // New user - go to create profile (OTP bypassed for testing)
        context.go(AppRoutes.createProfile, extra: formattedPhone);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = 'An error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.getStarted),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What's your phone number?",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              // Mock mode indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lavenderMist,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 16,
                      color: AppColors.primaryViolet,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Test Mode - OTP Skipped',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primaryViolet,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Phone input with fixed +880 prefix
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed country code
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '+880 ',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  // Phone input field
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                        _PhoneNumberFormatter(),
                      ],
                      style: Theme.of(context).textTheme.headlineSmall,
                      decoration: InputDecoration(
                        hintText: '1711-051800',
                        hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.softGrey.withValues(alpha: 0.5),
                            ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.paleGrey),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.paleGrey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryViolet, width: 2),
                        ),
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorText: _errorText,
                        counterText: '${_digitsOnly.length}/10',
                      ),
                      onSubmitted: (_) => _isValidPhone ? _continueWithPhone() : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Helper text
              Text(
                'Enter your 10-digit mobile number without the leading zero',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.softGrey,
                    ),
              ),
              const Spacer(),
              // Continue button
              PrimaryButton(
                text: 'Continue',
                onPressed: _isValidPhone ? _continueWithPhone : null,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom formatter to add dash after 4 digits: 1711-051800
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted;
    if (digits.length <= 4) {
      formatted = digits;
    } else {
      formatted = '${digits.substring(0, 4)}-${digits.substring(4)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

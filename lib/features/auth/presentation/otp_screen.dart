import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dikkhaai/app/router.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/core/constants/app_constants.dart';
import 'package:dikkhaai/core/widgets/primary_button.dart';
import 'package:dikkhaai/data/services/auth_service.dart';
import 'package:dikkhaai/data/services/storage_service.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _errorText;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = AppConstants.otpResendDuration.inSeconds;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  bool get _isValidOtp => _otpController.text.length == AppConstants.otpLength;

  Future<void> _verifyOtp() async {
    if (!_isValidOtp) {
      setState(() {
        _errorText = 'Please enter the 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final storage = ref.read(storageServiceProvider);
      
      final success = await authService.verifyOtp(
        widget.phoneNumber,
        _otpController.text,
      );

      if (success && mounted) {
        // Check if user profile exists
        final existingUser = storage.getCurrentUser();
        
        if (existingUser != null && existingUser.phone == widget.phoneNumber) {
          // Existing user, go to main
          context.go('${AppRoutes.main}/read');
        } else {
          // New user, go to profile creation
          context.go(AppRoutes.createProfile, extra: widget.phoneNumber);
        }
      } else if (mounted) {
        setState(() {
          _errorText = 'Invalid code. Please try again.';
        });
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

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;

    final authService = ref.read(authServiceProvider);
    await authService.sendOtp(widget.phoneNumber);
    _startResendTimer();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: AppColors.primaryViolet,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);
    final maskedPhone = authService.maskPhoneNumber(widget.phoneNumber);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.phone),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the 6-digit code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a code to $maskedPhone to verify your phone number',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.softGrey,
                    ),
              ),
              const SizedBox(height: 32),
              // OTP input
              TextField(
                controller: _otpController,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(AppConstants.otpLength),
                ],
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 8,
                    ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '• • • • • •',
                  hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.softGrey.withValues(alpha: 0.5),
                        letterSpacing: 8,
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
                  errorText: _errorText,
                ),
                onChanged: (value) {
                  if (_errorText != null) {
                    setState(() {
                      _errorText = null;
                    });
                  }
                  if (value.length == AppConstants.otpLength) {
                    _verifyOtp();
                  }
                },
              ),
              const SizedBox(height: 16),
              // Resend code
              GestureDetector(
                onTap: _resendCountdown > 0 ? null : _resendOtp,
                child: Text(
                  _resendCountdown > 0
                      ? 'Resend code in $_resendCountdown seconds'
                      : 'Resend code',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _resendCountdown > 0
                            ? AppColors.softGrey
                            : AppColors.primaryViolet,
                        fontWeight: _resendCountdown > 0
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                ),
              ),
              const Spacer(),
              // Verify button
              PrimaryButton(
                text: 'Verify Now',
                onPressed: _isValidOtp ? _verifyOtp : null,
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


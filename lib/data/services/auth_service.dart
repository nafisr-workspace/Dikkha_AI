import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dikkhaai/core/constants/app_constants.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  // Mock OTP sending - in Phase 2, this will use Firebase Phone Auth
  Future<bool> sendOtp(String phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In Phase 1, always succeed
    // In Phase 2, this will call Firebase
    return true;
  }

  // Mock OTP verification - in Phase 2, this will use Firebase Phone Auth
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In Phase 1, accept mock OTP
    return otp == AppConstants.mockOtp;
  }

  // Format phone number with country code
  String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }
    
    if (!cleaned.startsWith('880')) {
      cleaned = '880$cleaned';
    }
    
    return '+$cleaned';
  }

  // Mask phone number for display
  String maskPhoneNumber(String phone) {
    if (phone.length < 8) return phone;
    
    final prefix = phone.substring(0, phone.length - 6);
    return '$prefix XXXX-XXXXXX';
  }
}


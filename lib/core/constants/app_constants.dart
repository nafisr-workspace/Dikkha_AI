class AppConstants {
  // App Info
  static const String appName = 'Dikkha AI';
  static const String appTagline = 'Learn Faster, Go Further.';

  // Grades
  static const List<String> grades = ['Class 9', 'Class 10'];

  // Groups
  static const List<String> groups = ['Science', 'Commerce', 'Humanities', 'Other'];

  // Boards
  static const List<String> boards = [
    'Dhaka',
    'Chittagong',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
    'Comilla',
    'Jessore',
    'Dinajpur',
    'Madrasa',
    'Technical',
  ];

  // Subjects by Group
  static const Map<String, List<String>> subjectsByGroup = {
    'Science': [
      'Bangla',
      'English',
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'ICT',
      'Higher Math',
    ],
    'Commerce': [
      'Bangla',
      'English',
      'Mathematics',
      'Accounting',
      'Business Studies',
      'Finance & Banking',
      'ICT',
    ],
    'Humanities': [
      'Bangla',
      'English',
      'Mathematics',
      'History',
      'Geography',
      'Civics',
      'Economics',
      'ICT',
    ],
    'Other': [
      'Bangla',
      'English',
      'Mathematics',
      'ICT',
    ],
  };

  // OTP
  static const int otpLength = 6;
  static const String mockOtp = '123456';
  static const String bdCountryCode = '+880';

  // Timing
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration otpResendDuration = Duration(seconds: 60);
}


import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

class AIService {
  // Mock AI response - in Phase 2, this will call actual AI API
  Future<String> getResponse({
    required String message,
    required String subject,
    String? selectedText,
    String? imagePath,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock response based on context
    if (selectedText != null && selectedText.isNotEmpty) {
      return _generateExplanation(selectedText, subject);
    }

    if (imagePath != null) {
      return _generateImageResponse(message, subject);
    }

    return _generateGeneralResponse(message, subject);
  }

  String _generateExplanation(String text, String subject) {
    return '''
## ব্যাখ্যা (Explanation)

আপনি যে অংশটি নির্বাচন করেছেন: **"$text"**

এই বিষয়টি $subject-এর একটি গুরুত্বপূর্ণ অংশ।

### মূল ধারণা:
1. এটি মৌলিক নীতিগুলির উপর ভিত্তি করে তৈরি
2. বাস্তব জীবনে এর অনেক প্রয়োগ রয়েছে
3. পরীক্ষায় এই বিষয়ে প্রশ্ন আসতে পারে

### সূত্র (Formula):
\$\$E = mc^2\$\$

### উদাহরণ:
- প্রথম উদাহরণ
- দ্বিতীয় উদাহরণ

আরও প্রশ্ন থাকলে জিজ্ঞাসা করুন!
''';
  }

  String _generateImageResponse(String message, String subject) {
    return '''
## ছবি বিশ্লেষণ (Image Analysis)

আপনার পাঠানো ছবিটি দেখেছি। এটি $subject সম্পর্কিত।

### পর্যবেক্ষণ:
- এটি একটি সমস্যা/চিত্র যা $subject-এর সাথে সম্পর্কিত
- সমাধানের জন্য নিম্নলিখিত ধাপগুলি অনুসরণ করুন

### সমাধান:
**ধাপ ১:** প্রদত্ত তথ্য চিহ্নিত করুন
**ধাপ ২:** প্রয়োজনীয় সূত্র নির্বাচন করুন
**ধাপ ৩:** গণনা সম্পন্ন করুন

\$\$F = ma\$\$

যেখানে:
- \$F\$ = বল (Force)
- \$m\$ = ভর (Mass)
- \$a\$ = ত্বরণ (Acceleration)
''';
  }

  String _generateGeneralResponse(String message, String subject) {
    return '''
## উত্তর (Answer)

আপনার প্রশ্ন: **"$message"**

এই প্রশ্নটি $subject-এর একটি গুরুত্বপূর্ণ বিষয়।

### ব্যাখ্যা:
এই বিষয়ে বিস্তারিত বলতে গেলে, আমাদের কিছু মৌলিক ধারণা বুঝতে হবে:

1. **প্রথম বিষয়**: মূল সংজ্ঞা ও ধারণা
2. **দ্বিতীয় বিষয়**: প্রয়োগ ক্ষেত্র
3. **তৃতীয় বিষয়**: উদাহরণ

### গাণিতিক প্রকাশ:
\$\$\\frac{d}{dx}(x^n) = nx^{n-1}\$\$

### মনে রাখবেন:
> এই বিষয়টি ভালোভাবে বুঝে নিলে পরীক্ষায় ভালো করতে পারবেন।

আরও কোনো প্রশ্ন থাকলে নির্দ্বিধায় জিজ্ঞাসা করুন!
''';
  }
}


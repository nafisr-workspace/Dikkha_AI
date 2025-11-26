import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dikkhaai/data/models/quiz.dart';
import 'package:dikkhaai/data/models/flashcard.dart';

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

  // Generate quiz from selected text
  Future<List<QuizQuestion>> generateQuiz({
    required String selectedText,
    required String subject,
  }) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock quiz generation based on subject
    return _generateMockQuizQuestions(selectedText, subject);
  }

  // Generate flashcards from selected text
  Future<List<Flashcard>> generateFlashcards({
    required String selectedText,
    required String subject,
  }) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock flashcard generation based on subject
    return _generateMockFlashcards(selectedText, subject);
  }

  List<QuizQuestion> _generateMockQuizQuestions(String text, String subject) {
    // Generate context-aware mock questions based on subject
    switch (subject.toLowerCase()) {
      case 'physics':
        return [
          QuizQuestion(
            question: 'ভৌত রাশির একক কী দ্বারা প্রকাশ করা হয়?',
            options: ['SI একক', 'CGS একক', 'FPS একক', 'উপরের সবগুলো'],
            correctIndex: 3,
          ),
          QuizQuestion(
            question: 'দৈর্ঘ্যের SI একক কী?',
            options: ['সেন্টিমিটার', 'মিটার', 'কিলোমিটার', 'মিলিমিটার'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'পদার্থবিজ্ঞান মূলত কী অধ্যয়ন করে?',
            options: ['জীববিদ্যা', 'রসায়ন', 'প্রকৃতির মৌলিক নিয়মাবলী', 'ভূগোল'],
            correctIndex: 2,
          ),
        ];
      case 'mathematics':
      case 'higher math':
        return [
          QuizQuestion(
            question: r'$\frac{d}{dx}(x^2)$ এর মান কত?',
            options: [r'$x$', r'$2x$', r'$x^2$', r'$2$'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'একটি সমকোণী ত্রিভুজের কোণের সমষ্টি কত?',
            options: ['90°', '180°', '270°', '360°'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'পিথাগোরাসের সূত্র অনুযায়ী কোনটি সঠিক?',
            options: [
              r'$a^2 + b^2 = c^2$',
              r'$a + b = c$',
              r'$a^2 - b^2 = c^2$',
              r'$2a + 2b = c$'
            ],
            correctIndex: 0,
          ),
        ];
      case 'chemistry':
        return [
          QuizQuestion(
            question: 'পানির রাসায়নিক সংকেত কী?',
            options: [r'$H_2O$', r'$CO_2$', r'$NaCl$', r'$O_2$'],
            correctIndex: 0,
          ),
          QuizQuestion(
            question: 'পর্যায় সারণিতে মোট কতটি মৌল আছে?',
            options: ['100', '108', '118', '120'],
            correctIndex: 2,
          ),
          QuizQuestion(
            question: 'অক্সিজেনের পারমাণবিক সংখ্যা কত?',
            options: ['6', '7', '8', '9'],
            correctIndex: 2,
          ),
        ];
      case 'biology':
        return [
          QuizQuestion(
            question: 'কোষের শক্তিঘর কোনটি?',
            options: ['নিউক্লিয়াস', 'মাইটোকন্ড্রিয়া', 'রাইবোজোম', 'গলগি বডি'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'DNA এর পূর্ণরূপ কী?',
            options: [
              'Deoxyribonucleic Acid',
              'Dinucleic Acid',
              'Dioxynucleic Acid',
              'Dual Nucleic Acid'
            ],
            correctIndex: 0,
          ),
          QuizQuestion(
            question: 'সালোকসংশ্লেষণ কোথায় ঘটে?',
            options: ['মাইটোকন্ড্রিয়া', 'ক্লোরোপ্লাস্ট', 'নিউক্লিয়াস', 'রাইবোজোম'],
            correctIndex: 1,
          ),
        ];
      default:
        return [
          QuizQuestion(
            question: 'নিচের কোনটি "$subject" বিষয়ের সাথে সম্পর্কিত?',
            options: ['ধারণা ১', 'ধারণা ২', 'ধারণা ৩', 'সবগুলো'],
            correctIndex: 3,
          ),
          QuizQuestion(
            question: 'এই বিষয়ের মূল উদ্দেশ্য কী?',
            options: ['শেখা', 'বোঝা', 'প্রয়োগ করা', 'উপরের সবগুলো'],
            correctIndex: 3,
          ),
          QuizQuestion(
            question: 'শিক্ষার্থীদের জন্য কোন দক্ষতা সবচেয়ে গুরুত্বপূর্ণ?',
            options: ['মুখস্থ করা', 'বুঝে পড়া', 'শুধু পরীক্ষা দেওয়া', 'কিছুই না'],
            correctIndex: 1,
          ),
        ];
    }
  }

  List<Flashcard> _generateMockFlashcards(String text, String subject) {
    // Generate context-aware mock flashcards based on subject
    switch (subject.toLowerCase()) {
      case 'physics':
        return [
          Flashcard(
            front: 'ভৌত রাশি কাকে বলে?',
            back: 'যে সকল রাশি পরিমাপ করা যায় এবং যার একক ও মান আছে, তাদের ভৌত রাশি বলে।\n\nউদাহরণ: দৈর্ঘ্য, ভর, সময়, বেগ ইত্যাদি।',
          ),
          Flashcard(
            front: 'SI একক কী?',
            back: 'SI (International System of Units) হলো আন্তর্জাতিকভাবে স্বীকৃত একক পদ্ধতি।\n\n**মৌলিক একক:** মিটার (m), কিলোগ্রাম (kg), সেকেন্ড (s), অ্যাম্পিয়ার (A), কেলভিন (K), মোল (mol), ক্যান্ডেলা (cd)',
          ),
          Flashcard(
            front: r'নিউটনের দ্বিতীয় সূত্র কী?',
            back: r'বস্তুর ভরবেগের পরিবর্তনের হার প্রযুক্ত বলের সমানুপাতিক এবং বল যে দিকে ক্রিয়া করে পরিবর্তন সেদিকেই ঘটে।'
                '\n\n'
                r'**সূত্র:** $F = ma$'
                '\n\n'
                r'যেখানে $F$ = বল, $m$ = ভর, $a$ = ত্বরণ',
          ),
        ];
      case 'mathematics':
      case 'higher math':
        return [
          Flashcard(
            front: 'অন্তরীকরণ (Differentiation) কী?',
            back: r'অন্তরীকরণ হলো একটি ফাংশনের পরিবর্তনের হার নির্ণয় করার প্রক্রিয়া।'
                '\n\n'
                r'**মৌলিক সূত্র:**'
                '\n'
                r'$\frac{d}{dx}(x^n) = nx^{n-1}$'
                '\n\n'
                r'উদাহরণ: $\frac{d}{dx}(x^2) = 2x$',
          ),
          Flashcard(
            front: 'সমাকলন (Integration) কী?',
            back: r'সমাকলন হলো অন্তরীকরণের বিপরীত প্রক্রিয়া।'
                '\n\n'
                r'**মৌলিক সূত্র:**'
                '\n'
                r'$\int x^n dx = \frac{x^{n+1}}{n+1} + C$'
                '\n\n'
                r'যেখানে $C$ = ধ্রুবক',
          ),
          Flashcard(
            front: 'পিথাগোরাসের উপপাদ্য কী?',
            back: r'সমকোণী ত্রিভুজের অতিভুজের বর্গ অপর দুই বাহুর বর্গের সমষ্টির সমান।'
                '\n\n'
                r'**সূত্র:** $a^2 + b^2 = c^2$'
                '\n\n'
                r'যেখানে $c$ = অতিভুজ, $a$ ও $b$ = অপর দুই বাহু',
          ),
        ];
      case 'chemistry':
        return [
          Flashcard(
            front: 'পরমাণু কাকে বলে?',
            back: 'মৌলের ক্ষুদ্রতম কণা যা রাসায়নিক বিক্রিয়ায় অংশগ্রহণ করতে পারে এবং মৌলের সকল ধর্ম বজায় রাখে, তাকে পরমাণু বলে।'
                '\n\n'
                'পরমাণু তিনটি মৌলিক কণা দ্বারা গঠিত: প্রোটন, নিউট্রন ও ইলেকট্রন।',
          ),
          Flashcard(
            front: 'রাসায়নিক বন্ধন কী?',
            back: 'যে আকর্ষণ বলের মাধ্যমে একটি অণুতে পরমাণুসমূহ পরস্পরের সাথে যুক্ত থাকে, তাকে রাসায়নিক বন্ধন বলে।'
                '\n\n'
                '**প্রকারভেদ:**\n- আয়নিক বন্ধন\n- সমযোজী বন্ধন\n- ধাতব বন্ধন',
          ),
          Flashcard(
            front: r'অম্ল ও ক্ষারকের পার্থক্য কী?',
            back: r'**অম্ল:** পানিতে দ্রবীভূত হয়ে $H^+$ আয়ন দেয়। pH < 7'
                '\n\n'
                r'**ক্ষারক:** পানিতে দ্রবীভূত হয়ে $OH^-$ আয়ন দেয়। pH > 7'
                '\n\n'
                r'**নিরপেক্ষ:** pH = 7 (যেমন: বিশুদ্ধ পানি)',
          ),
        ];
      case 'biology':
        return [
          Flashcard(
            front: 'কোষ কাকে বলে?',
            back: 'জীবদেহের গঠন ও কাজের একক হলো কোষ।'
                '\n\n'
                '**দুই প্রকার:**\n- প্রোক্যারিওটিক কোষ (নিউক্লিয়াস ঝিল্লি নেই)\n- ইউক্যারিওটিক কোষ (নিউক্লিয়াস ঝিল্লি আছে)',
          ),
          Flashcard(
            front: 'সালোকসংশ্লেষণ কী?',
            back: r'সবুজ উদ্ভিদ সূর্যালোকের উপস্থিতিতে $CO_2$ ও $H_2O$ থেকে গ্লুকোজ ও $O_2$ তৈরি করে।'
                '\n\n'
                r'**সমীকরণ:**'
                '\n'
                r'$6CO_2 + 6H_2O \xrightarrow{আলো} C_6H_{12}O_6 + 6O_2$',
          ),
          Flashcard(
            front: 'DNA ও RNA এর পার্থক্য কী?',
            back: '**DNA:**\n- দ্বি-সূত্রক\n- ডিঅক্সিরাইবোজ শর্করা\n- থাইমিন বেস থাকে\n\n'
                '**RNA:**\n- একক সূত্রক\n- রাইবোজ শর্করা\n- ইউরাসিল বেস থাকে',
          ),
        ];
      default:
        return [
          Flashcard(
            front: '$subject বিষয়ের মূল ধারণা কী?',
            back: 'এই বিষয়টি শিক্ষার্থীদের জন্য গুরুত্বপূর্ণ। এখানে মূল ধারণাগুলো বোঝা প্রয়োজন।'
                '\n\n'
                'নিয়মিত অনুশীলন করলে এই বিষয়ে দক্ষতা অর্জন সম্ভব।',
          ),
          Flashcard(
            front: 'এই অংশের গুরুত্ব কী?',
            back: 'পরীক্ষায় এই অংশ থেকে প্রশ্ন আসার সম্ভাবনা বেশি।'
                '\n\n'
                'ভালোভাবে পড়ে এবং বুঝে নিলে পরীক্ষায় ভালো করা যাবে।',
          ),
          Flashcard(
            front: 'কীভাবে এই বিষয়টি মনে রাখবেন?',
            back: '**কৌশল:**\n- নিয়মিত পড়া\n- নোট করা\n- প্রশ্নোত্তর অনুশীলন\n- গ্রুপ স্টাডি',
          ),
        ];
    }
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


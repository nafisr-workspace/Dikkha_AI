import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dikkhaai/data/models/book.dart';
import 'package:dikkhaai/core/constants/app_constants.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository();
});

class BookRepository {
  // Get subjects for a user's grade and group
  List<String> getSubjects(String grade, String group) {
    return AppConstants.subjectsByGroup[group] ?? AppConstants.subjectsByGroup['Other']!;
  }

  // Get chapters for a subject
  List<Chapter> getChapters(String grade, String subject) {
    // In a real app, this would be fetched from a database or API
    // For now, return mock chapters based on subject
    final subjectLower = subject.toLowerCase();
    
    switch (subjectLower) {
      case 'physics':
        return _getPhysicsChapters(grade);
      case 'mathematics':
      case 'math':
        return _getMathChapters(grade);
      case 'chemistry':
        return _getChemistryChapters(grade);
      case 'biology':
        return _getBiologyChapters(grade);
      default:
        return _getGenericChapters(grade, subject);
    }
  }

  List<Chapter> _getPhysicsChapters(String grade) {
    return [
      Chapter(
        id: 'physics_ch1',
        number: 1,
        title: 'ভৌত রাশি এবং পরিমাপ (Physical Quantities and Measurement)',
        markdownPath: 'assets/books/$grade/physics/ch1.md',
      ),
      Chapter(
        id: 'physics_ch2',
        number: 2,
        title: 'গতি (Motion)',
        markdownPath: 'assets/books/$grade/physics/ch2.md',
      ),
      Chapter(
        id: 'physics_ch3',
        number: 3,
        title: 'বল এবং নিউটনের সূত্রাবলী (Force and Newton\'s Laws)',
        markdownPath: 'assets/books/$grade/physics/ch3.md',
      ),
      Chapter(
        id: 'physics_ch4',
        number: 4,
        title: 'কাজ, ক্ষমতা ও শক্তি (Work, Power and Energy)',
        markdownPath: 'assets/books/$grade/physics/ch4.md',
      ),
      Chapter(
        id: 'physics_ch5',
        number: 5,
        title: 'পদার্থের অবস্থা ও চাপ (States of Matter and Pressure)',
        markdownPath: 'assets/books/$grade/physics/ch5.md',
      ),
    ];
  }

  List<Chapter> _getMathChapters(String grade) {
    return [
      Chapter(
        id: 'math_ch1',
        number: 1,
        title: 'সেট ও ফাংশন (Sets and Functions)',
        markdownPath: 'assets/books/$grade/math/ch1.md',
      ),
      Chapter(
        id: 'math_ch2',
        number: 2,
        title: 'বীজগাণিতিক রাশি (Algebraic Expressions)',
        markdownPath: 'assets/books/$grade/math/ch2.md',
      ),
      Chapter(
        id: 'math_ch3',
        number: 3,
        title: 'সূচক ও লগারিদম (Indices and Logarithms)',
        markdownPath: 'assets/books/$grade/math/ch3.md',
      ),
    ];
  }

  List<Chapter> _getChemistryChapters(String grade) {
    return [
      Chapter(
        id: 'chem_ch1',
        number: 1,
        title: 'রসায়নের ধারণা (Introduction to Chemistry)',
        markdownPath: 'assets/books/$grade/chemistry/ch1.md',
      ),
      Chapter(
        id: 'chem_ch2',
        number: 2,
        title: 'পদার্থের গঠন (Structure of Matter)',
        markdownPath: 'assets/books/$grade/chemistry/ch2.md',
      ),
    ];
  }

  List<Chapter> _getBiologyChapters(String grade) {
    return [
      Chapter(
        id: 'bio_ch1',
        number: 1,
        title: 'জীবন পাঠ (Life Science)',
        markdownPath: 'assets/books/$grade/biology/ch1.md',
      ),
      Chapter(
        id: 'bio_ch2',
        number: 2,
        title: 'কোষ ও কোষ বিভাজন (Cell and Cell Division)',
        markdownPath: 'assets/books/$grade/biology/ch2.md',
      ),
    ];
  }

  List<Chapter> _getGenericChapters(String grade, String subject) {
    return [
      Chapter(
        id: '${subject.toLowerCase()}_ch1',
        number: 1,
        title: 'অধ্যায় ১ (Chapter 1)',
        markdownPath: 'assets/books/$grade/${subject.toLowerCase()}/ch1.md',
      ),
      Chapter(
        id: '${subject.toLowerCase()}_ch2',
        number: 2,
        title: 'অধ্যায় ২ (Chapter 2)',
        markdownPath: 'assets/books/$grade/${subject.toLowerCase()}/ch2.md',
      ),
    ];
  }

  // Load markdown content from assets
  Future<String> loadChapterContent(String markdownPath) async {
    try {
      final content = await rootBundle.loadString(markdownPath);
      return content;
    } catch (e) {
      // Return default content if file doesn't exist
      return _getDefaultContent();
    }
  }

  String _getDefaultContent() {
    return '''
# প্রথম ভাগ: বলবিদ্যা (Mechanics)

## অধ্যায় ১: ভৌত রাশি এবং পরিমাপ (Physical Quantities and Measurement)

### ১.১ পদার্থবিজ্ঞান কী?

পদার্থবিজ্ঞান হলো প্রকৃতির মৌলিক নিয়মাবলী অধ্যয়নের বিজ্ঞান। এটি পদার্থ, শক্তি, স্থান, কাল এবং তাদের মধ্যকার পারস্পরিক সম্পর্ক নিয়ে আলোচনা করে।

### ১.২ একক এবং মাত্রা (Units and Dimensions)

প্রতিটি ভৌত রাশির পরিমাপের জন্য একটি নির্দিষ্ট একক প্রয়োজন।

**SI এককসমূহ:**
- দৈর্ঘ্য: মিটার (m)
- ভর: কিলোগ্রাম (kg)
- সময়: সেকেন্ড (s)

**মাত্রা সমীকরণ:**

বেগের মাত্রা: \$[v] = [LT^{-1}]\$

ত্বরণের মাত্রা: \$[a] = [LT^{-2}]\$

### ১.৩ ত্রুটি এবং নির্ভুলতা (Errors and Accuracy)

পরিমাপে সর্বদা কিছু ত্রুটি থাকে। ত্রুটি দুই প্রকার:
1. **নিয়মিত ত্রুটি** (Systematic Error)
2. **এলোমেলো ত্রুটি** (Random Error)

---

## অধ্যায় ২: গতি (Motion)

### ২.১ সরণ, বেগ, ও ত্বরণ (Displacement, Velocity, and Acceleration)

**সরণ (Displacement):** কোনো বস্তুর প্রাথমিক অবস্থান থেকে চূড়ান্ত অবস্থানের দূরত্ব ও দিক।

**বেগ (Velocity):** একক সময়ে সরণের হার।

\$\$v = \\frac{\\Delta x}{\\Delta t}\$\$

**ত্বরণ (Acceleration):** একক সময়ে বেগের পরিবর্তনের হার।

\$\$a = \\frac{\\Delta v}{\\Delta t}\$\$

### ২.২ লেখচিত্রের মাধ্যমে গতির বর্ণনা (Graphical Description of Motion)

গতি বিশ্লেষণে বিভিন্ন লেখচিত্র ব্যবহার করা হয়:
- দূরত্ব-সময় লেখচিত্র
- বেগ-সময় লেখচিত্র
- ত্বরণ-সময় লেখচিত্র

### ২.৩ প্রাসের গতি (Projectile Motion)

প্রাসের গতির সমীকরণসমূহ:

অনুভূমিক দূরত্ব: \$x = v_0 \\cos\\theta \\cdot t\$

উল্লম্ব দূরত্ব: \$y = v_0 \\sin\\theta \\cdot t - \\frac{1}{2}gt^2\$

সর্বোচ্চ উচ্চতা: \$H = \\frac{v_0^2 \\sin^2\\theta}{2g}\$

পাল্লা: \$R = \\frac{v_0^2 \\sin 2\\theta}{g}\$

---

## অধ্যায় ৩: বল এবং নিউটনের সূত্রাবলী (Force and Newton's Laws)

### ৩.১ নিউটনের গতির প্রথম, দ্বিতীয় ও তৃতীয় সূত্র

**প্রথম সূত্র (জড়তার সূত্র):**
বাহ্যিক বল প্রয়োগ না করলে স্থির বস্তু স্থিরই থাকবে এবং গতিশীল বস্তু সমবেগে সরলরেখায় চলতে থাকবে।

**দ্বিতীয় সূত্র:**
বস্তুর ভরবেগের পরিবর্তনের হার প্রযুক্ত বলের সমানুপাতিক।

\$\$F = ma\$\$

**তৃতীয় সূত্র:**
প্রতিটি ক্রিয়ার একটি সমান ও বিপরীত প্রতিক্রিয়া আছে।

### ৩.২ ভরবেগ ও সংরক্ষণ (Momentum and Conservation)

ভরবেগ: \$p = mv\$

ভরবেগের সংরক্ষণ সূত্র: \$m_1v_1 + m_2v_2 = m_1v_1' + m_2v_2'\$

### ৩.৩ ঘর্ষণ (Friction)

ঘর্ষণ বল: \$f = \\mu N\$

যেখানে \$\\mu\$ হলো ঘর্ষণ গুণাঙ্ক এবং \$N\$ হলো লম্ব প্রতিক্রিয়া বল।
''';
  }
}


import 'package:flutter/material.dart';
import 'package:dikkhaai/app/theme.dart';

class SubjectChips extends StatelessWidget {
  final List<String> subjects;
  final String? selectedSubject;
  final void Function(String) onSubjectSelected;

  const SubjectChips({
    super.key,
    required this.subjects,
    this.selectedSubject,
    required this.onSubjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: subjects.map((subject) {
          final isSelected = subject == selectedSubject;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(subject),
              selected: isSelected,
              onSelected: (_) => onSubjectSelected(subject),
              selectedColor: AppColors.primaryViolet,
              backgroundColor: AppColors.pureWhite,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.onPrimary : AppColors.deepSlate,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryViolet : AppColors.paleGrey,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}


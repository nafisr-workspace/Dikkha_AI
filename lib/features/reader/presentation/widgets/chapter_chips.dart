import 'package:flutter/material.dart';
import 'package:dikkhaai/app/theme.dart';
import 'package:dikkhaai/data/models/book.dart';

class ChapterChips extends StatelessWidget {
  final List<Chapter> chapters;
  final int selectedIndex;
  final void Function(int) onChapterSelected;

  const ChapterChips({
    super.key,
    required this.chapters,
    required this.selectedIndex,
    required this.onChapterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chapters.asMap().entries.map((entry) {
          final index = entry.key;
          final chapter = entry.value;
          final isSelected = index == selectedIndex;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('Ch ${chapter.number}'),
              selected: isSelected,
              onSelected: (_) => onChapterSelected(index),
              selectedColor: AppColors.lavenderMist,
              backgroundColor: AppColors.pureWhite,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryViolet : AppColors.deepSlate,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryViolet : AppColors.paleGrey,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}


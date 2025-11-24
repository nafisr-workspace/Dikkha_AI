import 'package:flutter/material.dart';
import 'package:dikkhaai/app/theme.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String? hintText;
  final String? labelText;
  final void Function(T?)? onChanged;
  final String Function(T)? itemLabelBuilder;

  const AppDropdown({
    super.key,
    this.value,
    required this.items,
    this.hintText,
    this.labelText,
    this.onChanged,
    this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((item) {
        final label = itemLabelBuilder?.call(item) ?? item.toString();
        return DropdownMenuItem<T>(
          value: item,
          child: Text(label),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.softGrey),
      dropdownColor: AppColors.pureWhite,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}


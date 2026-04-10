import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A themed dropdown field with consistent styling.
class ObDropdown<T> extends HookWidget {
  const ObDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.labelText,
    super.key,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final String? labelText;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(hintText: hintText, labelText: labelText),
      isExpanded: true,
    );
}

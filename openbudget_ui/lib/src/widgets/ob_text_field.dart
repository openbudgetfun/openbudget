import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/widgets/ob_field_icon.dart';

/// A themed text field with consistent styling.
///
/// Its icons are centred in the 48pt slots the field lays them out in, so
/// even a bare `SkribbleIcon` sits inside the outline rather than on its
/// corner. In a plain `TextField`, use [ObFieldIcon] for the same result.
class ObTextField extends HookWidget {
  const ObTextField({
    this.controller,
    this.hintText,
    this.labelText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled = true,
    super.key,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    autofocus: autofocus,
    enabled: enabled,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    decoration: InputDecoration(
      hintText: hintText,
      labelText: labelText,
      errorText: errorText,
      prefixText: prefixText,
      prefixIcon: _centred(prefixIcon),
      suffixIcon: _centred(suffixIcon),
    ),
  );

  static Widget? _centred(Widget? icon) => icon == null
      ? null
      : Center(widthFactor: 1, heightFactor: 1, child: icon);
}

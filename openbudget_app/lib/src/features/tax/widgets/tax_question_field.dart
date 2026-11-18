import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/tax/tax_profile_form_values.dart';
import 'package:openbudget_app/src/features/tax/tax_question_labels.g.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The key of the field that asks the question stored under [questionKey],
/// so tests and page objects can find it without its wording.
Key taxQuestionFieldKey(String questionKey) =>
    ValueKey('tax-question-$questionKey');

/// The control for one tax profile question: a switch for yes or no, a
/// dropdown for a choice, a text field for a count or an amount, and a pair
/// of dropdowns for a day of the year. Wording comes from the question's
/// `AppLocalizations` keys through [taxQuestionLabel].
class TaxQuestionField extends HookWidget {
  const TaxQuestionField({
    required this.question,
    required this.values,
    required this.currency,
    required this.onChanged,
    this.error,
    this.padded = true,
    super.key,
  });

  final TaxProfileQuestion question;

  /// The form's current answers; the field reads only its own.
  final TaxFormValues values;

  /// The currency an amount question is asked in.
  final CurrencyCode currency;

  /// Reports a new answer for the given key. A month-and-day question
  /// reports its `<key>Month` and `<key>Day` separately.
  final void Function(String key, Object? value) onChanged;

  /// What is wrong with the typed text, when anything is.
  final TaxFieldError? error;

  /// Whether to pad the control like a row of the profile card. A switch
  /// always carries its own padding.
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = taxQuestionLabel(l10n, question.labelKey);
    final help = question.helpKey == null
        ? null
        : taxQuestionLabel(l10n, question.helpKey!);
    final fieldKey = taxQuestionFieldKey(question.key);

    return switch (question) {
      TaxBoolQuestion() => SwitchListTile(
        key: fieldKey,
        value: values[question.key] == true,
        onChanged: (value) => onChanged(question.key, value),
        title: Text(label),
        subtitle: help == null ? null : Text(help),
      ),
      final TaxChoiceQuestion choice => _Padded(
        enabled: padded,
        child: _Described(
          help: help,
          child: ObDropdown<String>(
            key: fieldKey,
            // Null is "none"; a dropdown value cannot be null while an item
            // stands for it, so it travels as the empty string.
            value: values[question.key] as String? ?? _noneValue,
            labelText: label,
            items: [
              if (choice.noneLabelKey case final noneKey?)
                DropdownMenuItem(
                  value: _noneValue,
                  child: Text(taxQuestionLabel(l10n, noneKey)),
                ),
              for (final option in choice.options)
                DropdownMenuItem(
                  value: option.value,
                  child: Text(taxQuestionLabel(l10n, option.labelKey)),
                ),
            ],
            onChanged: (value) => onChanged(
              question.key,
              value == null || value == _noneValue ? null : value,
            ),
          ),
        ),
      ),
      TaxCountQuestion() => _Padded(
        enabled: padded,
        child: _Described(
          help: help,
          child: _TaxTextQuestion(
            fieldKey: fieldKey,
            label: label,
            initialText: values[question.key] as String? ?? '',
            keyboardType: TextInputType.number,
            errorText: error == null ? null : l10n.taxProfileCountError,
            onChanged: (text) => onChanged(question.key, text),
          ),
        ),
      ),
      TaxMoneyQuestion() => _Padded(
        enabled: padded,
        child: _Described(
          help: help,
          child: _TaxTextQuestion(
            fieldKey: fieldKey,
            label: label,
            initialText: values[question.key] as String? ?? '',
            prefixText: currency.symbol,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: error == null ? null : l10n.taxProfileAmountError,
            onChanged: (text) => onChanged(question.key, text),
          ),
        ),
      ),
      final TaxMonthDayQuestion monthDay => _Padded(
        enabled: padded,
        child: _Described(
          help: help,
          child: _MonthDayQuestion(
            key: fieldKey,
            label: label,
            monthLabel: taxQuestionLabel(l10n, monthDay.monthLabelKey),
            dayLabel: taxQuestionLabel(l10n, monthDay.dayLabelKey),
            month: values['${question.key}Month']! as int,
            day: values['${question.key}Day']! as int,
            onMonthChanged: (month) {
              onChanged('${question.key}Month', month);
              // Keep the day inside the chosen month.
              final lastDay = taxDaysInMonth(month);
              if ((values['${question.key}Day']! as int) > lastDay) {
                onChanged('${question.key}Day', lastDay);
              }
            },
            onDayChanged: (day) => onChanged('${question.key}Day', day),
          ),
        ),
      ),
    };
  }
}

const _noneValue = '';

/// The padding every control but a switch sits in, matching a switch row's.
class _Padded extends HookWidget {
  const _Padded({required this.child, required this.enabled});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) => enabled
      ? Padding(padding: const EdgeInsets.all(SpacingTokens.md), child: child)
      : child;
}

/// [child] with its [help] under it, when there is any.
class _Described extends HookWidget {
  const _Described({required this.child, this.help});

  final Widget child;
  final String? help;

  @override
  Widget build(BuildContext context) {
    final text = help;
    if (text == null) return child;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        const SizedBox(height: SpacingTokens.xs),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.ob.mutedInk,
          ),
        ),
      ],
    );
  }
}

/// A text field that owns its controller and reports every edit. It keeps
/// the text it was given when it leaves the form and comes back.
class _TaxTextQuestion extends HookWidget {
  const _TaxTextQuestion({
    required this.fieldKey,
    required this.label,
    required this.initialText,
    required this.keyboardType,
    required this.onChanged,
    this.prefixText,
    this.errorText,
  });

  final Key fieldKey;
  final String label;
  final String initialText;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final String? prefixText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initialText);
    return ObTextField(
      key: fieldKey,
      controller: controller,
      labelText: label,
      prefixText: prefixText,
      keyboardType: keyboardType,
      errorText: errorText,
      onChanged: onChanged,
    );
  }
}

/// A month and a day of the month, side by side, or one above the other
/// when large text leaves too little room for both.
class _MonthDayQuestion extends HookWidget {
  const _MonthDayQuestion({
    required this.label,
    required this.monthLabel,
    required this.dayLabel,
    required this.month,
    required this.day,
    required this.onMonthChanged,
    required this.onDayChanged,
    super.key,
  });

  final String label;
  final String monthLabel;
  final String dayLabel;
  final int month;
  final int day;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onDayChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthField = ObDropdown<int>(
      value: month,
      labelText: monthLabel,
      items: [
        for (var value = 1; value <= 12; value++)
          DropdownMenuItem(
            value: value,
            child: Text(DateFormat.MMMM().format(DateTime(2024, value))),
          ),
      ],
      onChanged: (value) {
        if (value != null) onMonthChanged(value);
      },
    );
    final dayField = ObDropdown<int>(
      value: day,
      labelText: dayLabel,
      items: [
        for (var value = 1; value <= taxDaysInMonth(month); value++)
          DropdownMenuItem(value: value, child: Text('$value')),
      ],
      onChanged: (value) {
        if (value != null) onDayChanged(value);
      },
    );
    // Two dropdowns stop fitting side by side once the text is about
    // one and a half times larger.
    final stacked = MediaQuery.textScalerOf(context).scale(16) > 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.ob.mutedInk,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        if (stacked) ...[
          monthField,
          const SizedBox(height: SpacingTokens.md),
          dayField,
        ] else
          Row(
            children: [
              Expanded(child: monthField),
              const SizedBox(width: SpacingTokens.md),
              Expanded(child: dayField),
            ],
          ),
      ],
    );
  }
}

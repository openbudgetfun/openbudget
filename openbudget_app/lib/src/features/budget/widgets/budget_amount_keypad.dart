import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

Future<String?> showBudgetAmountKeypadSheet({
  required BuildContext context,
  required CurrencyCode currencyCode,
  required String initialInput,
  String? title,
  bool allowNegative = true,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  backgroundColor: OpenBudgetPalette.transparentFor(Theme.of(context)),
  builder: (sheetContext) => _BudgetAmountSheet(
    currencyCode: currencyCode,
    initialInput: initialInput,
    title: title,
    allowNegative: allowNegative,
  ),
);

class BudgetAmountField extends StatelessWidget {
  const BudgetAmountField({
    required this.labelText,
    required this.currencyCode,
    required this.inputValue,
    required this.onTap,
    this.prefixIcon,
    this.hintText,
    this.enabled = true,
    super.key,
  });

  final String labelText;
  final CurrencyCode currencyCode;
  final String inputValue;
  final VoidCallback onTap;
  final Widget? prefixIcon;
  final String? hintText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final displayText = formatBudgetAmountInputForField(
      input: inputValue,
      currencyCode: currencyCode,
    );

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(RadiusTokens.md),
      child: InputDecorator(
        isEmpty: inputValue.isEmpty,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          prefixText: '${currencyCode.symbol} ',
          suffixIcon: const Icon(Icons.dialpad_rounded),
          enabled: enabled,
        ),
        child: Text(displayText, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

class BudgetAmountKeypad extends StatelessWidget {
  const BudgetAmountKeypad({
    required this.inputValue,
    required this.onChanged,
    this.onSubmit,
    this.onClear,
    this.allowNegative = true,
    super.key,
  });

  final String inputValue;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmit;
  final VoidCallback? onClear;
  final bool allowNegative;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canSubmit = inputValue.isNotEmpty && inputValue != '-';

    Widget key(
      String label, {
      VoidCallback? onPressed,
      bool primary = false,
      bool accent = false,
      Widget? child,
      Key? buttonKey,
    }) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xs),
        child: FilledButton(
          key: buttonKey,
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: primary
                ? OpenBudgetPalette.bgBrandFor(Theme.of(context))
                : OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
            foregroundColor: primary
                ? OpenBudgetPalette.fgOnBrandFor(Theme.of(context))
                : accent
                ? OpenBudgetPalette.bgBrandFor(Theme.of(context))
                : OpenBudgetPalette.fgPrimaryEmphasisFor(Theme.of(context)),
            side: primary
                ? BorderSide.none
                : BorderSide(
                    color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
                  ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.sm),
            ),
            minimumSize: const Size.fromHeight(48),
            elevation: 0,
          ),
          child: child ?? Text(label),
        ),
      ),
    );

    void appendDigit(String digit) {
      if (inputValue.length >= 9) return;
      onChanged('$inputValue$digit');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            key(
              '7',
              onPressed: () => appendDigit('7'),
              accent: true,
              buttonKey: const Key('budget-keypad-digit-7'),
            ),
            key(
              '8',
              onPressed: () => appendDigit('8'),
              accent: true,
              buttonKey: const Key('budget-keypad-digit-8'),
            ),
            key(
              '9',
              onPressed: () => appendDigit('9'),
              accent: true,
              buttonKey: const Key('budget-keypad-digit-9'),
            ),
            key(
              '-',
              onPressed: allowNegative
                  ? () {
                      if (inputValue.isEmpty) return;
                      onChanged(
                        inputValue.startsWith('-')
                            ? inputValue.substring(1)
                            : '-$inputValue',
                      );
                    }
                  : null,
              accent: true,
              buttonKey: const Key('budget-keypad-minus'),
            ),
          ],
        ),
        Row(
          children: [
            key(
              '4',
              onPressed: () => appendDigit('4'),
              accent: true,
              buttonKey: const Key('budget-keypad-digit-4'),
            ),
            key(
              '5',
              onPressed: () => appendDigit('5'),
              accent: true,
              buttonKey: const Key('budget-keypad-digit-5'),
            ),
            key(
              '6',
              onPressed: () => appendDigit('6'),
              accent: true,
              buttonKey: const Key('budget-keypad-digit-6'),
            ),
            key(
              '+',
              onPressed: () {
                if (inputValue.startsWith('-')) {
                  onChanged(inputValue.substring(1));
                }
              },
              accent: true,
              buttonKey: const Key('budget-keypad-plus'),
            ),
          ],
        ),
        Row(
          children: [
            key(
              '1',
              onPressed: () => appendDigit('1'),
              accent: true,
              buttonKey: const Key('budget-keypad-digit-1'),
            ),
            key(
              '2',
              onPressed: () => appendDigit('2'),
              accent: true,
              buttonKey: const Key('budget-keypad-digit-2'),
            ),
            key(
              '3',
              onPressed: () => appendDigit('3'),
              accent: true,
              buttonKey: const Key('budget-keypad-digit-3'),
            ),
            key(
              '=',
              onPressed: canSubmit ? onSubmit : null,
              accent: true,
              buttonKey: const Key('budget-keypad-equals'),
            ),
          ],
        ),
        Row(
          children: [
            key(
              'x',
              onPressed: onClear ?? () => onChanged(''),
              child: const Icon(Icons.close_rounded),
              buttonKey: const Key('budget-keypad-clear'),
            ),
            key(
              '0',
              onPressed: () => appendDigit('0'),
              accent: true,
              buttonKey: const Key('budget-keypad-digit-0'),
            ),
            key(
              '',
              onPressed: () {
                if (inputValue.isEmpty) return;
                onChanged(inputValue.substring(0, inputValue.length - 1));
              },
              child: const Icon(Icons.backspace_outlined),
              buttonKey: const Key('budget-keypad-backspace'),
            ),
            key(
              l10n.dialogDone,
              onPressed: canSubmit ? onSubmit : null,
              primary: true,
              child: const Icon(Icons.subdirectory_arrow_left_rounded),
              buttonKey: const Key('budget-keypad-done'),
            ),
          ],
        ),
      ],
    );
  }
}

class _BudgetAmountSheet extends HookWidget {
  const _BudgetAmountSheet({
    required this.currencyCode,
    required this.initialInput,
    required this.allowNegative,
    this.title,
  });

  final CurrencyCode currencyCode;
  final String initialInput;
  final bool allowNegative;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final input = useState(initialInput);
    final cents = parseBudgetAmountInputToCents(
      input: input.value,
      currencyCode: currencyCode,
    );

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: OpenBudgetPalette.bgTertiaryFor(Theme.of(context)),
          border: Border(
            top: BorderSide(
              color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
            ),
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(RadiusTokens.md),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.sm,
            SpacingTokens.sm,
            SpacingTokens.sm,
            SpacingTokens.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                title ?? l10n.transactionAmountLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                formatCents(cents ?? 0, currencyCode),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              BudgetAmountKeypad(
                inputValue: input.value,
                allowNegative: allowNegative,
                onChanged: (next) => input.value = next,
                onClear: () => input.value = '',
                onSubmit: () => Navigator.of(context).pop(input.value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int? parseBudgetAmountInputToCents({
  required String input,
  required CurrencyCode currencyCode,
}) {
  if (input.isEmpty || input == '-') return null;
  final isNegative = input.startsWith('-');
  final digits = input.replaceAll('-', '');
  final units = int.tryParse(digits);
  if (units == null) return null;
  final cents = units * _pow10(currencyCode.decimals);
  return isNegative ? -cents : cents;
}

String formatBudgetAmountInputForField({
  required String input,
  required CurrencyCode currencyCode,
}) {
  if (input.isEmpty) return '';
  final cents = parseBudgetAmountInputToCents(
    input: input,
    currencyCode: currencyCode,
  );
  if (cents == null) return '';
  final divisor = _pow10(currencyCode.decimals);
  final value = cents / divisor;
  return value.toStringAsFixed(currencyCode.decimals);
}

String budgetAmountInputFromCents({
  required int cents,
  required CurrencyCode currencyCode,
}) {
  final divisor = _pow10(currencyCode.decimals);
  final units = (cents / divisor).round();
  return units.toString();
}

int _pow10(int exponent) {
  var result = 1;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}

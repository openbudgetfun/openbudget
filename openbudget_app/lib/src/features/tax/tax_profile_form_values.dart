import 'package:openbudget_core/openbudget_core.dart';

/// What was wrong with the text typed into a count or amount question.
enum TaxFieldError {
  /// Not a whole number of zero or more.
  count,

  /// Not an amount with at most the currency's decimals.
  amount,
}

/// A form's current answers, keyed by [TaxProfileQuestion.key].
///
/// A yes-or-no question holds a `bool`, a pick-one question its chosen
/// value as a `String` (null for "none"), a count or amount question the
/// text as typed, and a month-and-day question two `int`s under
/// `<key>Month` and `<key>Day`.
typedef TaxFormValues = Map<String, Object?>;

/// The key of the question that picks the kind of books, which also
/// decides which other questions are asked.
const taxEntityKindKey = 'entityKind';

/// The form values for [questions]: what the user has [edits] so far, else
/// the [stored] answer of the profile (see [TaxProfile.toAnswers]), else
/// the blank answer of the question's type.
///
/// Amounts are shown in the currency's [decimals], and a zero count or
/// amount is shown empty.
TaxFormValues taxFormValues({
  required List<TaxProfileQuestion> questions,
  required Map<String, Object?> stored,
  required TaxFormValues edits,
  required int decimals,
}) {
  Object? pick(String key) => edits.containsKey(key) ? edits[key] : stored[key];

  final values = <String, Object?>{};
  for (final question in questions) {
    final key = question.key;
    switch (question) {
      case TaxBoolQuestion():
        values[key] = pick(key) == true;
      case TaxChoiceQuestion():
        final chosen = pick(key);
        final known = question.options.any((option) => option.value == chosen);
        values[key] = known
            ? chosen
            : question.noneLabelKey == null
            ? question.options.first.value
            : null;
      case TaxCountQuestion():
        values[key] = _text(pick(key), (count) => '$count');
      case TaxMoneyQuestion():
        values[key] = _text(
          pick(key),
          (minor) => formatMinorUnits(minor, decimals),
        );
      case TaxMonthDayQuestion():
        values['${key}Month'] = pick('${key}Month') ?? 1;
        values['${key}Day'] = pick('${key}Day') ?? 1;
    }
  }
  return values;
}

/// Whether [question] is shown for the current [values].
bool taxQuestionVisible(TaxProfileQuestion question, TaxFormValues values) {
  final condition = question.visibleWhen;
  return condition == null || condition.matches(values[condition.key]);
}

/// The answers [values] hold for [questions], ready for
/// [TaxProfile.withAnswers], and the questions whose text does not parse.
///
/// Empty text is zero. A visible question with bad text is an error and
/// the form is not saved; a hidden one with bad text keeps the profile's
/// stored answer, because the user cannot see what to fix.
({Map<String, Object?> answers, Map<String, TaxFieldError> errors})
taxFormAnswers({
  required List<TaxProfileQuestion> questions,
  required TaxFormValues values,
  required int decimals,
}) {
  final answers = <String, Object?>{};
  final errors = <String, TaxFieldError>{};
  for (final question in questions) {
    final key = question.key;
    switch (question) {
      case TaxBoolQuestion() || TaxChoiceQuestion():
        answers[key] = values[key];
      case TaxMonthDayQuestion():
        answers['${key}Month'] = values['${key}Month'];
        answers['${key}Day'] = values['${key}Day'];
      case TaxCountQuestion():
        final count = _wholeCount(values[key]);
        if (count != null) {
          answers[key] = count;
        } else if (taxQuestionVisible(question, values)) {
          errors[key] = TaxFieldError.count;
        }
      case TaxMoneyQuestion():
        final minor = _minorUnits(values[key], decimals);
        if (minor != null) {
          answers[key] = minor;
        } else if (taxQuestionVisible(question, values)) {
          errors[key] = TaxFieldError.amount;
        }
    }
  }
  return (answers: answers, errors: errors);
}

/// The days [month] has, counting 29 February: a year end that has no leap
/// day is treated as 28 February by the rule pack.
int taxDaysInMonth(int month) => switch (month) {
  2 => 29,
  4 || 6 || 9 || 11 => 30,
  _ => 31,
};

/// A stored count or amount as editable text: empty for zero.
String _text(Object? value, String Function(int) format) => switch (value) {
  final String text => text,
  final int number when number != 0 => format(number),
  _ => '',
};

/// The whole number of zero or more typed in [value], where empty is zero,
/// or null when it is anything else.
int? _wholeCount(Object? value) {
  final text = '$value'.trim();
  if (text.isEmpty) return 0;
  final count = int.tryParse(text);
  return count != null && count >= 0 ? count : null;
}

/// The amount typed in [value] in minor units, where empty is zero, or
/// null when it is not an amount.
int? _minorUnits(Object? value, int decimals) {
  final text = '$value'.trim();
  return text.isEmpty ? 0 : parseMinorUnits(text, decimals);
}

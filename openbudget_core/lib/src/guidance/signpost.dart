import 'package:meta/meta.dart';

/// A condition that routes the conversation, or an opportunity, to a
/// qualified professional before anything else is said.
///
/// From the `tax-planning-guardrails` skill's product-rules reference,
/// section 3. When any trigger holds, the guide says why it is signposting
/// and offers to prepare the figures and questions to bring.
@immutable
final class SignpostTrigger {
  const SignpostTrigger({required this.id, required this.condition});

  /// Stable identifier: `residence-unclear`.
  final String id;

  /// The condition, in one sentence.
  final String condition;
}

/// Every signpost trigger, shared by the prompt, the packs and MCP
/// clients.
const List<SignpostTrigger> signpostTriggers = [
  SignpostTrigger(
    id: 'residence-unclear',
    condition:
        'Residence or domicile is unclear, the user arrived in or left the '
        'country this year, or is a UK arrival after ten or more years '
        'abroad.',
  ),
  SignpostTrigger(
    id: 'us-person-abroad',
    condition:
        'The user is a US person living abroad, or has income in more than '
        'one country.',
  ),
  SignpostTrigger(
    id: 'owner-managed-structures',
    condition:
        'Owner-managed company structure questions: shares, holdings, GmbH, '
        'entity election, group structures, associated companies, share '
        'issues, loans above £10,000 to or from the company, or dividend '
        'legality doubts.',
  ),
  SignpostTrigger(
    id: 'should-i-investment',
    condition:
        'A "should I" or "which one" question about a specific investment, '
        'fund, ISA, pension provider, withdrawal, property or crypto '
        'position.',
  ),
  SignpostTrigger(
    id: 'large-saving',
    condition:
        "An estimated saving above the threshold the jurisdiction's rule "
        'data sets.',
  ),
  SignpostTrigger(
    id: 'authority-contact',
    condition:
        'Letters, penalties, investigations, amended returns, late filings '
        'from the authority, or anything that sounds like evasion.',
  ),
  SignpostTrigger(
    id: 'trusts-and-family',
    condition: 'Trusts, inheritance, large gifts, divorce or bankruptcy.',
  ),
  SignpostTrigger(
    id: 'missing-facts',
    condition:
        'The relief needs facts the books do not hold, such as qualifying '
        'conditions or evidence.',
  ),
  SignpostTrigger(
    id: 'unverified-rule',
    condition:
        'A rule is secondary, inferred or announced and the user wants to '
        'act before it is confirmed.',
  ),
];

/// The signpost sentence the guide uses when a trigger fires.
const signpostWording =
    'This is a point where a qualified adviser can look at your whole '
    'situation. I can prepare the figures and questions to bring.';

/// The trigger with [id], or null when no such trigger exists.
SignpostTrigger? signpostTrigger(String id) {
  for (final trigger in signpostTriggers) {
    if (trigger.id == id) {
      return trigger;
    }
  }
  return null;
}

// Each bullet is one sentence wrapped across lines, so adjacent strings
// inside these lists are deliberate.
// ignore_for_file: no_adjacent_strings_in_list

import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/legal/legal_document.dart';

/// Where to get help, served at `/support`. The App Store listing's
/// support link points here.
LegalDocument support(SiteConfig config) {
  final email = config.supportEmail;
  final mail = '[$email](mailto:$email)';
  return LegalDocument(
    path: '/support',
    title: 'Support',
    description:
        'Get help with OpenBudget: contact us, report a bug, manage your '
        'subscription or delete your account.',
    updated: config.legalUpdated,
    intro: [
      LegalParagraph(
        'Stuck, or found something that looks wrong? Email $mail and we '
        'will get back to you.',
      ),
    ],
    sections: [
      LegalSection('Report a bug or suggest an idea', [
        LegalParagraph(
          'OpenBudget is open source. You can report bugs and suggest '
          'features on [GitHub](${config.sourceUrl}/issues). Please leave '
          'amounts, account names and other personal details out of public '
          'issues, and email us instead if a bug needs them.',
        ),
      ]),
      const LegalSection('Your subscription', [
        LegalList([
          'App Store: open Settings on your iPhone or iPad, tap your name, '
              'then Subscriptions.',
          'Google Play: open the Play Store, tap your profile, then Payments '
              'and subscriptions.',
          'Card: open OpenBudget Plus in the app and tap Manage.',
          'USDC: cancel from the Solana wallet that approved the '
              'subscription.',
        ]),
      ]),
      const LegalSection('Your data', [
        LegalList([
          'Export your budget from Settings, Export Budget, or your tax '
              'summary from the Taxes screen.',
          '[Delete your account](/delete-account) in the app or by email.',
          'Read how we handle your data in our [privacy policy](/privacy), '
              'and the rules of the service in our [terms](/terms).',
        ]),
      ]),
      const LegalSection('Before you ask', [
        LegalParagraph(
          'Tax reports and the Money guide are guidance, not regulated '
          'financial or tax advice, so we cannot advise on your personal tax '
          'position. The [questions on our home page](/#questions) cover '
          'how envelope budgeting, currencies and pricing work.',
        ),
      ]),
    ],
  );
}

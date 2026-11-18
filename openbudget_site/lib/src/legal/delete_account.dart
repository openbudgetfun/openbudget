// Each bullet is one sentence wrapped across lines, so adjacent strings
// inside these lists are deliberate.
// ignore_for_file: no_adjacent_strings_in_list

import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/legal/legal_document.dart';

/// How to delete an OpenBudget account, served at `/delete-account`.
///
/// Google Play asks for a web page that explains account deletion without
/// installing the app; this is it.
LegalDocument deleteAccount(SiteConfig config) {
  final email = config.supportEmail;
  final request =
      '[$email](mailto:$email?subject=Delete%20my%20OpenBudget%20account)';
  return LegalDocument(
    path: '/delete-account',
    title: 'Deleting your account',
    description:
        'How to delete your OpenBudget account and data, in the app or by '
        'email, and what is kept afterwards.',
    updated: config.legalUpdated,
    intro: const [
      LegalParagraph(
        'You can delete your OpenBudget account and its data whenever you '
        'like. Export anything you want to keep first, because deletion '
        'cannot be undone.',
      ),
    ],
    sections: [
      LegalSection('In the app', [
        LegalList([
          'Open OpenBudget on your phone, computer or at '
              '[${config.webAppUrl.host}](${config.webAppUrl}) and sign in.',
          'Go to Settings, then Account settings.',
          'Tap Delete account and confirm.',
        ]),
        const LegalParagraph(
          'If you subscribe to OpenBudget Plus through the App Store or '
          'Google Play, cancel it in your store account too. Deleting your '
          'account does not stop store billing on its own.',
        ),
      ]),
      LegalSection('By email', [
        LegalParagraph(
          'If you cannot sign in, email $request from the address on your '
          'account. We will confirm the request with you and delete the '
          'account within 30 days.',
        ),
      ]),
      const LegalSection('What is deleted', [
        LegalList([
          'Your sign-in details and settings.',
          'The books you own, with their accounts, transactions, envelopes, '
              'goals, recurring transactions, rules, journals and change '
              'history.',
          'Linked bank connections and crypto wallets, including the '
              'encrypted tokens and keys behind them.',
          'Tax profiles and categories.',
          'Money guide conversations and suggestions, your AI provider '
              'settings, and every agent access token.',
        ]),
      ]),
      LegalSection('What is kept', [
        const LegalList([
          'Payment and subscription records we must keep for tax and '
              'accounting law, usually for six to ten years.',
          'Purchase records that Apple, Google, RevenueCat and Stripe hold '
              'under their own policies, and USDC payments, which stay on the '
              'public Solana blockchain.',
          'Request logs that banking, blockchain and AI services keep under '
              'their own retention rules.',
          'Copies in our backups, until those backups expire.',
        ]),
        LegalParagraph(
          'Our [privacy policy](/privacy) has the details, and $request can '
          'answer any question.',
        ),
      ]),
    ],
  );
}

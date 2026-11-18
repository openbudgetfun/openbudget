// Each bullet is one sentence wrapped across lines, so adjacent strings
// inside these lists are deliberate.
// ignore_for_file: no_adjacent_strings_in_list

import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/legal/legal_document.dart';

/// The terms of service, served at `/terms`.
LegalDocument termsOfService(SiteConfig config) {
  final email = config.supportEmail;
  final mail = '[$email](mailto:$email)';
  return LegalDocument(
    path: '/terms',
    title: 'Terms of service',
    description:
        'The agreement between you and OpenBudget when you use the apps, '
        'the web app and OpenBudget Plus.',
    updated: config.legalUpdated,
    intro: const [
      LegalParagraph(
        'These terms are the agreement between you and the team that runs '
        'OpenBudget ("we") when you use the OpenBudget apps, the web app, '
        'the API and OpenBudget Plus (together, "the service"). By creating '
        'an account or using the service, you agree to them.',
      ),
    ],
    sections: [
      const LegalSection('Your account', [
        LegalList([
          'You must be at least 16, or the age of digital consent where you '
              'live if that is higher, to use OpenBudget.',
          'Give accurate sign-in details and keep them, and any access '
              'tokens you create, private. You are responsible for what '
              'happens under your account and its tokens.',
          'You can stop using OpenBudget and delete your account at any '
              'time.',
        ]),
      ]),
      const LegalSection('Your data', [
        LegalParagraph(
          'What you put into OpenBudget stays yours. You give us permission '
          'to store, process and display it only to run the service for you, '
          'as described in our [privacy policy](/privacy). You can export it '
          'at any time.',
        ),
      ]),
      const LegalSection('Guidance, not advice', [
        LegalParagraph(
          'OpenBudget helps you organise your money and prepare for tax. Tax '
          'reports, tax-saving ideas, the Money guide and anything an agent '
          'suggests are general guidance based on the figures you entered '
          'and the rules we have researched. They are not regulated '
          'financial, investment, legal or tax advice, and they may be '
          'incomplete, out of date or wrong for your situation. Check '
          'important decisions, and anything you file with a tax authority, '
          'with a qualified adviser.',
        ),
        LegalParagraph(
          'Exchange rates, crypto prices and bank or blockchain data come '
          'from third parties and may be delayed or inaccurate. OpenBudget '
          'shows where each figure comes from and how old it is so you can '
          'judge it.',
        ),
      ]),
      const LegalSection('OpenBudget Plus', [
        LegalList([
          r'OpenBudget Plus costs $20 a month, billed in US dollars, and '
              r'includes $5 of Money guide usage each month. Unused usage '
              'does not carry over. We will tell you before the price or '
              'the included usage changes.',
          'If you subscribe through the App Store or Google Play, that store '
              'bills you, your subscription renews automatically until you '
              'cancel it in your store account, and refunds follow the '
              "store's rules.",
          'If you subscribe by card, Stripe bills you each month until you '
              'cancel with Manage on the OpenBudget Plus screen.',
          'If you subscribe with USDC, you approve a monthly payment from '
              'your Solana wallet. Each payment covers 30 days, and you cancel '
              'from the wallet that approved the subscription. Blockchain '
              'payments cannot be reversed.',
          'When you cancel, Plus stays active until the end of the period '
              'you have paid for. Except where the law or a store requires '
              'otherwise, payments are not refunded.',
        ]),
      ]),
      const LegalSection('Using OpenBudget fairly', [
        LegalParagraph('Do not:'),
        LegalList([
          "Use OpenBudget for anything illegal, or to handle other people's "
              'money or data without their permission.',
          'Try to break, overload, probe or get around the security or '
              'usage limits of the service.',
          'Use the Money guide, the API or access tokens to resell the '
              'service or run it as a service for others.',
          'Add wallets, bank accounts or data you have no right to use.',
        ]),
        LegalParagraph(
          'We may suspend or close an account that breaks these terms, '
          'after warning you where we reasonably can.',
        ),
      ]),
      LegalSection('Open source', [
        LegalParagraph(
          "OpenBudget's code is published under the "
          '[Apache License 2.0](${config.sourceUrl}/blob/main/LICENSE). '
          'That licence covers the code. These terms cover the service we '
          'run. The OpenBudget name and logo are not licensed for other '
          'products.',
        ),
      ]),
      const LegalSection('Third-party services', [
        LegalParagraph(
          'Bank connections, payments, app stores, blockchains and AI '
          'providers, including any provider or agent you connect yourself, '
          'are run by others under their own terms. We are not responsible '
          'for how they work.',
        ),
      ]),
      const LegalSection('Changes and availability', [
        LegalParagraph(
          'We keep improving OpenBudget, so features change. We work to keep '
          'the service running, but it may sometimes be unavailable, and we '
          'may stop offering it. If we do, we will give you at least 30 '
          "days' notice to export your data. We will tell you in the app or "
          'by email before changes to these terms take effect. If you keep '
          'using OpenBudget afterwards, the new terms apply.',
        ),
      ]),
      const LegalSection('Liability', [
        LegalParagraph(
          'The service is provided "as is". As far as the law allows, we are '
          'not liable for indirect or consequential losses, for decisions '
          'you make based on OpenBudget, or for penalties or interest from '
          'tax filings, and our total liability to you is limited to what '
          'you paid us in the 12 months before the claim. Nothing in these '
          'terms limits rights you have as a consumer that the law does not '
          'let us exclude.',
        ),
      ]),
      LegalSection('Contact', [
        LegalParagraph('Questions about these terms: $mail.'),
      ]),
    ],
  );
}

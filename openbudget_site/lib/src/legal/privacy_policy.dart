// Each bullet is one sentence wrapped across lines, so adjacent strings
// inside these lists are deliberate.
// ignore_for_file: no_adjacent_strings_in_list

import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/legal/legal_document.dart';

/// The privacy policy, served at `/privacy`.
///
/// Every statement here follows what the code collects and sends. When a
/// feature starts collecting something new, or sends data to a new
/// service, update this page and the store answers in
/// `openbudget_app/fastlane/store-privacy.md` in the same pull request.
LegalDocument privacyPolicy(SiteConfig config) {
  final email = config.supportEmail;
  final mail = '[$email](mailto:$email)';
  return LegalDocument(
    path: '/privacy',
    title: 'Privacy policy',
    description:
        'What OpenBudget collects, why, who it goes to, and how to see, '
        'export or delete it.',
    updated: config.legalUpdated,
    intro: [
      const LegalParagraph(
        'OpenBudget is an envelope budgeting app for iPhone, iPad, Android, '
        'the web and desktop. This policy explains what we collect when you '
        'use it, why, who it goes to, and the choices you have. "We" means '
        'the team that runs OpenBudget.',
      ),
      const LegalParagraph(
        'The short version: we store what you put into OpenBudget so it '
        'works on every device, we never sell it, we show no ads, and we do '
        'not track you across other apps or websites.',
      ),
      LegalParagraph(
        "OpenBudget's code is [open source](${config.sourceUrl}), so you "
        'can check every statement on this page against what the app and '
        'server actually do.',
      ),
    ],
    sections: [
      const LegalSection('What we collect', [
        LegalParagraph('Your account'),
        LegalList([
          'Your email address, and a scrambled (hashed) version of your '
              'password if you sign in with email. We never store the '
              'password itself.',
          'If you sign in with Apple or Google, the account identifier '
              'they give us, your email address, and your name if you choose '
              'to share it.',
          'Your settings, such as your display currency.',
        ]),
        LegalParagraph('What you put into your budget'),
        LegalList([
          'Your books: their names, country, currency, time zone and tax '
              'year.',
          'Accounts, balances, transactions, payees, envelopes, goals, '
              'notes, recurring transactions, rules, journals and anything '
              'you import from a CSV file.',
          'A history of changes to your books, so you can see who changed '
              'what and undo mistakes.',
          'Your tax profile answers, such as where you are tax resident, '
              'your filing status and the allowances that apply to you. We '
              'never ask for a tax identification or social security '
              'number.',
        ]),
        LegalParagraph('Bank connections (optional)'),
        LegalList([
          'When you link a bank, our banking partner Plaid shares the '
              'account names, balances and transactions you allow. We store '
              'the access token Plaid gives us encrypted, and never see your '
              'bank login.',
        ]),
        LegalParagraph('Crypto wallets (optional)'),
        LegalList([
          'The public address or extended public key you add, the chains '
              'it is on, and the holdings and transactions we read from '
              'those public blockchains. Extended public keys are stored '
              'encrypted.',
          'We never ask for a private key or recovery phrase. If you paste '
              'one, the app clears it immediately and sends nothing.',
        ]),
        LegalParagraph('The Money guide (OpenBudget Plus)'),
        LegalList([
          'Your conversations with the Money guide, the suggestions it makes '
              'and whether you applied them, and how much of your monthly '
              'allowance you have used.',
          'If you connect your own AI provider, its address, model name and '
              'API key. The key is stored encrypted.',
          'If you create access tokens for your own agents, a one-way hash '
              'of each token, so we can check it but cannot read it back.',
        ]),
        LegalParagraph('Subscriptions'),
        LegalList([
          'Whether you have OpenBudget Plus, how you pay for it, and when it '
              'renews or ends.',
          'For purchases through the App Store or Google Play, the store '
              'transaction details our billing partner RevenueCat passes on. '
              'For card payments, the customer reference Stripe gives us. For '
              'USDC payments, the Solana wallet address you subscribe from '
              'and the payment transactions.',
          'We never see or store your card number.',
        ]),
        LegalParagraph('Usage and technical data'),
        LegalList([
          'Server logs that record which features were called, when, how '
              'long they took and any errors, linked to your account so we '
              'can fix problems.',
          'In the released apps, product analytics through PostHog, such as '
              'app opens and which features are used. Analytics use a random '
              'identifier, are not linked to your account, name or email, '
              'and never include the contents of your budget. We do not '
              'record your screen.',
          'The phone apps check our update service, Shorebird, for small '
              'updates. That check sends the app version and platform, not '
              'anything about you.',
        ]),
      ]),
      const LegalSection('How we use it', [
        LegalList([
          'To run OpenBudget: store and sync your budget, calculate balances, '
              'net worth and tax figures, read your linked banks and wallets, '
              'and answer your questions in the Money guide.',
          'To sign you in, keep your account secure, and send the emails the '
              'service needs, such as verification codes.',
          'To process your subscription.',
          'To find and fix bugs and understand which features are used, so '
              'we can improve them.',
          'To meet legal obligations, such as keeping payment records.',
        ]),
        LegalParagraph(
          'We do not sell your data, use it for advertising, or use your '
          'budget to train AI models. Where the law asks for a legal basis, '
          'we rely on providing the service you asked for, our legitimate '
          'interest in keeping it secure and working, and legal obligations.',
        ),
      ]),
      const LegalSection('Who we share it with', [
        LegalParagraph(
          'We share data only with services that help us run OpenBudget, '
          'only what each one needs, and only to do that job:',
        ),
        LegalList([
          'Cloud hosting providers, which run our servers and database.',
          'An email delivery provider, which sends sign-in codes and service '
              'emails.',
          '[Plaid](https://plaid.com/legal/#end-user-privacy-policy), when '
              'you link a bank.',
          'Blockchain data services, when you add a wallet. They receive the '
              'wallet address and network only, never your name, email or '
              'account. Today these are Helius (Solana), mempool.space and '
              'Blockstream (Bitcoin), and the XRP Ledger public servers '
              '(xrplcluster.com and Ripple).',
          'Price services CoinGecko, DefiLlama, Jupiter and Magic Eden, which '
              'receive the names of the coins and tokens to price, never your '
              'addresses. Exchange rates come from currencyapi.com, which '
              'receives no data about you.',
          'The AI provider behind the Money guide. By default this is '
              '[OpenCode Zen](https://opencode.ai), which receives your '
              'messages and the budget figures the guide looks up to answer '
              'them. If you connect your own provider, that data goes to the '
              'provider you chose instead, under its terms.',
          '[RevenueCat](https://www.revenuecat.com/privacy/), Apple and '
              'Google for in-app subscriptions, and '
              '[Stripe](https://stripe.com/privacy) for card payments. '
              'Payments made in USDC are recorded on the public Solana '
              'blockchain.',
          '[PostHog](https://posthog.com/privacy) for the anonymous product '
              'analytics described above.',
          'Agents you connect with an access token, which can read your '
              'budgets and tax reports until you revoke the token.',
        ]),
        LegalParagraph(
          'We may also disclose data if the law requires it, to protect '
          "people's safety, or as part of a merger or sale of OpenBudget, "
          'in which case this policy continues to apply.',
        ),
      ]),
      LegalSection('Keeping it and deleting it', [
        const LegalParagraph(
          'We keep your data while you have an account, so your budget is '
          'there when you come back.',
        ),
        LegalParagraph(
          'You can delete your account at any time in the app under '
          'Settings, Account settings, Delete account, or by emailing $mail. '
          'Deleting your account deletes your sign-in details and the books '
          'you own, with their accounts, transactions, wallets, bank '
          'connections, tax profiles and Money guide conversations. '
          '[Deleting your account](/delete-account) explains the steps and '
          'what is kept.',
        ),
        const LegalParagraph(
          'Some records stay after deletion: payment records we must keep '
          'for tax and accounting law, purchase records held by Apple, '
          'Google, RevenueCat and Stripe under their own policies, and '
          'request logs the services above keep under their own retention '
          'rules. Copies in our backups are overwritten as backups expire.',
        ),
      ]),
      LegalSection('Your choices and rights', [
        const LegalList([
          'See and export your data: Settings, Export Budget copies all of '
              'your budget data, and the Taxes screen exports your tax '
              'summary.',
          'Correct it: edit or delete anything you have entered at any '
              'time.',
          'Disconnect: unlink a bank or remove a wallet, and revoke agent '
              'access tokens, from Settings.',
          'Delete it: delete your account as described above.',
        ]),
        LegalParagraph(
          'Depending on where you live, including the UK, the European '
          'Economic Area and California, you may also have the right to '
          'request a copy of your data, object to or restrict how we use '
          'it, and complain to your data protection authority. Email $mail '
          'and we will respond within one month. We will not treat you '
          'differently for using these rights. We do not sell or share '
          'personal information for cross-context behavioural advertising.',
        ),
      ]),
      const LegalSection('Security', [
        LegalParagraph(
          'Data travels to and from OpenBudget over encrypted connections. '
          'Bank tokens, AI provider keys and wallet keys are encrypted in our '
          'database, and agent access tokens are stored only as one-way '
          'hashes. No system is perfectly secure, so if we learn of a breach '
          'that affects you, we will tell you and the authorities as the law '
          'requires.',
        ),
      ]),
      const LegalSection('Where your data is processed', [
        LegalParagraph(
          'OpenBudget and the services above may process your data in the '
          'United States and other countries. When data leaves the UK or '
          'the European Economic Area, we rely on the safeguards the law '
          'provides, such as standard contractual clauses.',
        ),
      ]),
      const LegalSection('Children', [
        LegalParagraph(
          'OpenBudget is not meant for children under 16, and we do not '
          'knowingly collect data from them. If you believe a child has '
          'given us data, contact us and we will delete it.',
        ),
      ]),
      LegalSection('Changes and contact', [
        LegalParagraph(
          'If we change this policy, we will update the date at the top. For '
          'a significant change, we will also tell you in the app or by '
          'email before it takes effect. '
          'Questions or requests: $mail.',
        ),
      ]),
    ],
  );
}

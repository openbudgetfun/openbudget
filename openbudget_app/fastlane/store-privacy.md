# Store privacy answers

The answers for App Store Connect's **App Privacy** questionnaire and Google Play's **Data safety** form, with a summary of the privacy policy they rest on. The full policy is the page at <https://openbudget.app/privacy> (`openbudget_site/lib/src/legal/privacy_policy.dart`).

Everything here was derived from the code on 18 November 2026. When a feature collects something new or calls a new outside service, update this file, the policy page and the store forms together.

## Privacy policy summary

- OpenBudget is cloud-first: what people enter is stored on the OpenBudget server so it is the same on every device.
- It collects an email address (and a name if Apple or Google share one), the budget, account, transaction, books and tax profile data people enter, optional bank data through Plaid, optional public wallet addresses, Money guide conversations, and subscription status.
- It never asks for tax identification numbers, private keys or recovery phrases, and never sees card numbers.
- Data is used to run the service, secure accounts, process subscriptions and fix problems. It is not sold, not used for advertising, and not used to track people across apps or sites.
- Analytics (PostHog) run only in release builds, use a random identifier, and are not linked to the account.
- People can export their budget and tax summary, and delete their account in the app or through <https://openbudget.app/delete-account>.

## What the code collects, and where it goes

| Data                                                         | Where it comes from in the code                                                         | Stored by OpenBudget                                   | Sent to                                                                                               |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| Email, password hash, Apple or Google account identifier     | `openbudget_server/lib/src/auth/` (`serverpod_auth_idp`)                                | Yes                                                    | The SMTP provider (email address and verification code); Apple or Google during sign-in               |
| Books, accounts, transactions, envelopes, journals, notes    | `budget/`, `accounts/`, `transactions/`, `ledger/` and related server folders           | Yes                                                    | Nobody, except the Money guide provider when the guide looks figures up                               |
| Change history                                               | `audit/audit_event.spy.yaml`                                                            | Yes                                                    | Nobody                                                                                                |
| Tax profile answers (no identification numbers)              | `tax/tax_profile.spy.yaml`                                                              | Yes                                                    | The Money guide provider when the guide reads a tax report                                            |
| Bank accounts and transactions                               | `plaid/` and `plaid_flutter`                                                            | Yes; the Plaid access token is sealed with AES-256-GCM | Plaid                                                                                                 |
| Wallet addresses and extended public keys                    | `wallets/`                                                                              | Yes; extended keys are sealed                          | Helius, mempool.space, Blockstream, xrplcluster.com and Ripple receive the address and network only   |
| Coin and token identifiers                                   | `wallets/prices/`, `jupiter_price_client.dart`, `magic_eden_nft_price_client.dart`      | Prices only                                            | CoinGecko, DefiLlama, Jupiter and Magic Eden; never addresses                                         |
| Money guide messages, proposals and usage                    | `agent/`, `money_guide/`                                                                | Yes                                                    | OpenCode Zen, or the provider the person configured                                                   |
| Own-provider API key, agent access tokens                    | `agent/agent_provider_settings_service.dart`, `agent/agent_token_endpoint.dart`         | Key sealed with AES-256-GCM; tokens as SHA-256 hashes  | The key goes only to the provider it belongs to                                                       |
| Subscription status and store transaction references         | `billing/`, `purchases_flutter`                                                         | Yes                                                    | RevenueCat with Apple or Google; Stripe; the Solana network for USDC subscriptions                    |
| Server session logs (endpoint, time, duration, errors, user) | Serverpod session logging                                                               | Yes                                                    | Nobody                                                                                                |
| Product analytics with a random identifier                   | `openbudget_app/lib/src/analytics/` (`posthog_flutter`, release builds with a key only) | No                                                     | PostHog. The app calls no `identify`, registers no screen observer and does not enable session replay |
| App version and platform for update checks                   | `shorebird_code_push`                                                                   | No                                                     | Shorebird                                                                                             |

The app requests no device permissions for location, contacts, photos, camera, microphone or tracking.

## App Store Connect: App Privacy

Answer **Yes** to "Do you or your third-party partners collect data from this app?".

| Data type                                    | Collected | Linked to the person | Used for tracking | Purposes          |
| -------------------------------------------- | --------- | -------------------- | ----------------- | ----------------- |
| Contact Info: Email Address                  | Yes       | Yes                  | No                | App Functionality |
| Contact Info: Name                           | Yes       | Yes                  | No                | App Functionality |
| Financial Info: Other Financial Info         | Yes       | Yes                  | No                | App Functionality |
| Purchases: Purchase History                  | Yes       | Yes                  | No                | App Functionality |
| User Content: Other User Content             | Yes       | Yes                  | No                | App Functionality |
| Identifiers: User ID                         | Yes       | Yes                  | No                | App Functionality |
| Identifiers: Device ID                       | Yes       | No                   | No                | Analytics         |
| Usage Data: Product Interaction              | Yes       | No                   | No                | Analytics         |
| Financial Info: Payment Info                 | No        |                      |                   |                   |
| Location, Contacts, Health, Browsing History | No        |                      |                   |                   |
| Diagnostics: Crash Data                      | No        |                      |                   |                   |

- "Other Financial Info" covers budgets, balances, transactions, wallet holdings and tax profile answers.
- "Other User Content" covers Money guide conversations and notes.
- Payment Info is "No" because Apple handles the payment and the app never receives card details.
- The app does not track, so it needs no App Tracking Transparency prompt.

## Google Play: Data safety

| Question                                                 | Answer                                                                                           |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Does your app collect or share any required user data?   | Yes                                                                                              |
| Is all collected data encrypted in transit?              | Yes                                                                                              |
| Do you provide a way for users to request data deletion? | Yes: <https://openbudget.app/delete-account>                                                     |
| Is data shared with third parties?                       | No. Every outside service acts as a service provider, or receives data because the person asked. |

| Data type                                         | Collected | Required or optional                       | Purposes                              |
| ------------------------------------------------- | --------- | ------------------------------------------ | ------------------------------------- |
| Personal info: Email address                      | Yes       | Required                                   | App functionality, Account management |
| Personal info: Name                               | Yes       | Optional                                   | Account management                    |
| Personal info: User IDs                           | Yes       | Required                                   | App functionality, Account management |
| Financial info: Purchase history                  | Yes       | Optional                                   | App functionality                     |
| Financial info: Other financial info              | Yes       | Required                                   | App functionality                     |
| App activity: Other user-generated content        | Yes       | Optional                                   | App functionality                     |
| App activity: App interactions                    | Yes       | Required (no opt-out in the app yet)       | Analytics                             |
| Device or other IDs                               | Yes       | Required (the random analytics identifier) | Analytics                             |
| Financial info: User payment info, Credit score   | No        |                                            |                                       |
| Location, Messages, Photos, Contacts, Health, Web | No        |                                            |                                       |

Play also asks for the account deletion URL under **App content > Data safety > Account deletion**: use <https://openbudget.app/delete-account>.

## Check before submitting

These are facts the code cannot settle, or gaps found while writing this file:

- **Account deletion must work in the app.** Apple (guideline 5.1.1(v)) and Google Play both require it for apps with sign-up. The server had no account deletion endpoint when this was written, and the policy and deletion page describe it as available.
- **The Settings screen must open the privacy policy and terms.** Both tiles showed "coming soon" when this was written.
- **The support mailbox must exist.** Every page prints `SiteConfig.supportEmail`.
- **Name the hosting and email providers** in the policy if you want to be specific, and confirm where the server runs. The policy says "the United States and other countries".
- **Have the terms of service reviewed.** They are a plain-language draft with no governing-law clause, because the operating entity and its country are not in the repository.
- **PostHog.** If the release build sets `POSTHOG_API_KEY`, the analytics rows above apply. If it does not, analytics are off and the two Analytics rows can be answered "No".

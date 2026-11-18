# Store listing

The words for the App Store and Google Play listings, kept in the layout [fastlane](https://docs.fastlane.tools) reads, so they can be reviewed in pull requests and uploaded with one command or pasted by hand.

| Path                                                 | Store field                                 | Limit            |
| ---------------------------------------------------- | ------------------------------------------- | ---------------- |
| `metadata/ios/en-US/name.txt`                        | App Store name                              | 30 characters    |
| `metadata/ios/en-US/subtitle.txt`                    | App Store subtitle (the tagline)            | 30 characters    |
| `metadata/ios/en-US/promotional_text.txt`            | Promotional text, editable without a review | 170 characters   |
| `metadata/ios/en-US/description.txt`                 | Description                                 | 4,000 characters |
| `metadata/ios/en-US/keywords.txt`                    | Keywords, comma separated                   | 100 characters   |
| `metadata/ios/en-US/release_notes.txt`               | What's New in This Version                  | 4,000 characters |
| `metadata/ios/en-US/{marketing,support,privacy}_url` | The listing's three links                   |                  |
| `metadata/ios/{copyright,*_category}.txt`            | Copyright line and categories               |                  |
| `metadata/android/en-US/title.txt`                   | Google Play app name                        | 30 characters    |
| `metadata/android/en-US/short_description.txt`       | Short description (the tagline)             | 80 characters    |
| `metadata/android/en-US/full_description.txt`        | Full description                            | 4,000 characters |
| `metadata/android/en-US/changelogs/default.txt`      | Release notes for any version code          | 500 characters   |
| `store-privacy.md`                                   | App Privacy and Data safety answers         |                  |

`test/store/store_metadata_test.dart` fails when a file is missing, empty or over its limit, and when the two descriptions drift apart.

## Writing rules

- Follow the voice in `docs/branding.md`: plain, warm, specific, and no exclamation marks about money.
- Claim only what the released app does. The wallet line names Bitcoin, Solana and the XRP Ledger because those are the chains the server reads today.
- Keep the guidance disclaimer and the auto-renewal sentence in both descriptions; the stores check for them.
- The two descriptions are the same text apart from the billing sentence under PRICING.
- Keywords must not repeat words already in the name or subtitle, and take no spaces after commas.
- Release notes follow the user changesets (`user_feat`, `user_improve`, `user_fix`) for the version, shortened to fit. `monochange run notes` renders the full list.

## Uploading

Nothing uploads automatically. From `openbudget_app/`, once fastlane has store credentials:

```sh
# App Store Connect: text only, no binary and no screenshots.
fastlane deliver --metadata_path fastlane/metadata/ios --skip_binary_upload --skip_screenshots

# Google Play: text only.
fastlane supply --metadata_path fastlane/metadata/android --skip_upload_apk --skip_upload_aab --skip_upload_images --skip_upload_screenshots
```

## Still done by hand

- Screenshots and the Google Play feature graphic.
- The App Privacy and Data safety forms, from `store-privacy.md`.
- Age rating and content rating questionnaires, and Google Play's Financial features declaration.
- A demo account for App Review, entered in App Store Connect and never committed here.
- The OpenBudget Plus subscription products and their review details.

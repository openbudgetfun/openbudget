---
openbudget_site: feat
openbudget_app: docs
---

# Add the store listing text and the policy pages it links to

`openbudget_app/fastlane/metadata/` holds the App Store and Google Play listing in the layout fastlane reads: name, tagline, description, keywords, promotional text, release notes and links. `openbudget_app/fastlane/store-privacy.md` gives the answers for App Store Connect's App Privacy form and Google Play's Data safety form, with a table mapping each kind of data to the code that collects it and the services that receive it. `test/store/store_metadata_test.dart` fails when a field is missing or over its store limit, or when the two descriptions drift apart.

`openbudget_site` now serves four more pages, written as data in `lib/src/legal/` and laid out by one `LegalPage` component:

- `/privacy`: the privacy policy, naming every outside service that receives data.
- `/terms`: the terms of service.
- `/support`: where to get help and how to manage a subscription.
- `/delete-account`: how to delete an account in the app or by email, for Google Play's account deletion requirement.

`SiteConfig` gains `supportEmail` and `legalUpdated`, the footer links to the new pages, and `tool/build.dart` fails unless all four were written. The root README now describes the product, fixes the clone URL and project structure, and documents releases, the store listing and privacy.

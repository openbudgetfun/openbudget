import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'legal_links_provider.g.dart';

/// The public pages the app links to from Settings.
///
/// Both stores require a reachable privacy policy, and the App Store asks
/// for it inside the app as well as on the listing.
abstract final class LegalLinks {
  /// The privacy policy on the public site.
  static final Uri privacyPolicy = Uri.parse('https://openbudget.app/privacy');

  /// The terms of service on the public site.
  static final Uri termsOfService = Uri.parse('https://openbudget.app/terms');
}

/// Opens a public page outside the app, behind an interface for tests.
// ignore: one_member_abstracts
abstract interface class LegalLinkLauncher {
  /// Returns false when the platform has nothing to open the page with.
  Future<bool> open(Uri url);
}

/// Opens pages with the platform's browser.
class SystemLegalLinkLauncher implements LegalLinkLauncher {
  const SystemLegalLinkLauncher();

  @override
  Future<bool> open(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);
}

/// The launcher Settings uses for the privacy policy and terms.
@Riverpod(keepAlive: true)
LegalLinkLauncher legalLinkLauncher(Ref ref) => const SystemLegalLinkLauncher();

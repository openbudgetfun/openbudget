import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'plus_url_launcher_provider.g.dart';

/// Opens a checkout or management URL, behind an interface for tests.
// ignore: one_member_abstracts
abstract interface class PlusUrlLauncher {
  Future<bool> open(Uri url);
}

/// Opens URLs with the platform browser.
///
/// On web the same tab is used so the return link lands inside the app; on
/// desktop the system browser opens outside the app.
class SystemPlusUrlLauncher implements PlusUrlLauncher {
  const SystemPlusUrlLauncher();

  @override
  Future<bool> open(Uri url) {
    if (kIsWeb) {
      return launchUrl(url, webOnlyWindowName: '_self');
    }
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

/// The launcher used for Stripe and store management links.
@Riverpod(keepAlive: true)
PlusUrlLauncher plusUrlLauncher(Ref ref) => const SystemPlusUrlLauncher();

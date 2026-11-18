import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'tax_url_launcher_provider.g.dart';

/// Opens links the tax screens hand out, behind an interface for tests.
abstract interface class TaxUrlLauncher {
  /// Opens a web page about taxes (an authority or a source) outside the app.
  ///
  /// Returns false when the platform has nothing to open it with.
  Future<bool> openPage(Uri url);

  /// Starts the download behind a signed export link.
  ///
  /// Returns false when the platform has nothing to open it with.
  Future<bool> openDownload(Uri url);
}

/// Opens links with the platform's browser or default app.
class SystemTaxUrlLauncher implements TaxUrlLauncher {
  const SystemTaxUrlLauncher();

  @override
  Future<bool> openPage(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);

  /// On the web the download starts in the same tab: the response is an
  /// attachment, so the page stays put, and a new tab opened after an
  /// asynchronous call is the kind browsers block as a pop-up.
  @override
  Future<bool> openDownload(Uri url) {
    if (kIsWeb) {
      return launchUrl(url, webOnlyWindowName: '_self');
    }
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

/// The launcher the tax screens use.
@Riverpod(keepAlive: true)
TaxUrlLauncher taxUrlLauncher(Ref ref) => const SystemTaxUrlLauncher();

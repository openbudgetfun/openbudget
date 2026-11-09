import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:openbudget_site/site_config.dart';

/// The app's downloads, drawn as postage stamps.
///
/// A download with a URL is a link; one without is a cancelled stamp that
/// says "Coming soon" and goes nowhere. [SiteConfig] decides which is which.
final class DownloadStamps extends StatelessComponent {
  const DownloadStamps({required this.config, super.key});

  /// Where the downloads point.
  final SiteConfig config;

  @override
  Component build(BuildContext context) => div(classes: 'downloads', [
    p(classes: 'downloads-label', [
      Component.text(
        config.hasPendingDownloads
            ? 'Apps for every desk are on their way'
            : 'Get the app',
      ),
    ]),
    ul(classes: 'stamps', [
      for (final download in config.downloads)
        li([_DownloadStamp(download: download)]),
    ]),
  ]);
}

final class _DownloadStamp extends StatelessComponent {
  const _DownloadStamp({required this.download});

  final Download download;

  @override
  Component build(BuildContext context) {
    final face = [
      span(classes: 'stamp-note', [
        Component.text(download.isAvailable ? 'Download for' : 'Coming soon'),
      ]),
      span(classes: 'stamp-name', [Component.text(download.platform.label)]),
    ];
    final attributes = {'data-platform': download.platform.name};
    if (download.url case final url?) {
      return a(
        href: url.toString(),
        classes: 'stamp',
        attributes: attributes,
        face,
      );
    }
    return span(classes: 'stamp is-soon', attributes: attributes, face);
  }
}

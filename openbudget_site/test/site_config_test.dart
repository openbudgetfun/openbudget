import 'package:openbudget_site/site_config.dart';
import 'package:test/test.dart';

void main() {
  group('SiteConfig', () {
    test('lists the downloads in the order the site shows them', () {
      expect(
        siteConfig.downloads.map((download) => download.platform),
        DownloadPlatform.values,
      );
    });

    test('a download is available exactly when it has a URL', () {
      final config = SiteConfig(
        siteUrl: Uri.parse('https://example.test/'),
        webAppUrl: Uri.parse('https://app.example.test'),
        sourceUrl: Uri.parse('https://source.example.test'),
        googlePlayUrl: Uri.parse('https://play.example.test/openbudget'),
      );

      expect(
        {
          for (final download in config.downloads)
            download.platform: download.isAvailable,
        },
        {
          DownloadPlatform.appStore: false,
          DownloadPlatform.googlePlay: true,
          DownloadPlatform.macOS: false,
          DownloadPlatform.windows: false,
          DownloadPlatform.linux: false,
        },
      );
      expect(config.hasPendingDownloads, isTrue);
    });

    test('has no pending downloads once every URL is set', () {
      expect(_everyDownloadLive().hasPendingDownloads, isFalse);
    });

    test('resolves site paths to absolute URLs', () {
      expect(
        siteConfig.resolve('/og.png').toString(),
        'https://openbudget.app/og.png',
      );
      expect(siteConfig.resolve('/').toString(), 'https://openbudget.app/');
    });

    test('the published config points at the app and the source', () {
      expect(siteConfig.webAppUrl.toString(), 'https://app.openbudget.app');
      expect(
        siteConfig.sourceUrl.toString(),
        'https://github.com/openbudgetfun/openbudget',
      );
      expect(siteConfig.hasPendingDownloads, isTrue);
    });
  });
}

SiteConfig _everyDownloadLive() => SiteConfig(
  siteUrl: Uri.parse('https://example.test/'),
  webAppUrl: Uri.parse('https://app.example.test'),
  sourceUrl: Uri.parse('https://source.example.test'),
  appStoreUrl: Uri.parse('https://apps.example.test/openbudget'),
  googlePlayUrl: Uri.parse('https://play.example.test/openbudget'),
  macOSUrl: Uri.parse('https://example.test/OpenBudget.dmg'),
  windowsUrl: Uri.parse('https://example.test/OpenBudget.msix'),
  linuxUrl: Uri.parse('https://example.test/OpenBudget.AppImage'),
);

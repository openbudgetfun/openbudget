/// Every URL the landing page links to.
///
/// The site renders all of its outbound links from one [SiteConfig]. A
/// download whose URL is null renders as an honest "coming soon" stamp;
/// giving it a URL turns that stamp into a live link on the next build.
library;

/// A place OpenBudget can be installed from.
enum DownloadPlatform {
  appStore('App Store'),
  googlePlay('Google Play'),
  macOS('macOS'),
  windows('Windows'),
  linux('Linux');

  const DownloadPlatform(this.label);

  /// The store or operating system, as people say it.
  final String label;
}

/// One download, live or not yet available.
final class Download {
  const Download(this.platform, this.url);

  /// Where the download is for.
  final DownloadPlatform platform;

  /// The store listing or installer; null until it exists.
  final Uri? url;

  /// Whether the download has somewhere to go.
  bool get isAvailable => url != null;
}

/// The links the site renders.
final class SiteConfig {
  SiteConfig({
    required this.siteUrl,
    required this.webAppUrl,
    required this.sourceUrl,
    this.appStoreUrl,
    this.googlePlayUrl,
    this.macOSUrl,
    this.windowsUrl,
    this.linuxUrl,
  });

  /// Where this site is published; canonical and social links start here.
  final Uri siteUrl;

  /// The OpenBudget web app, the primary call to action.
  final Uri webAppUrl;

  /// The public source repository.
  final Uri sourceUrl;

  /// The App Store listing, once the iOS app ships.
  final Uri? appStoreUrl;

  /// The Google Play listing, once the Android app ships.
  final Uri? googlePlayUrl;

  /// The macOS download, once it ships.
  final Uri? macOSUrl;

  /// The Windows download, once it ships.
  final Uri? windowsUrl;

  /// The Linux download, once it ships.
  final Uri? linuxUrl;

  /// Every download, in the order the site shows them.
  List<Download> get downloads => [
    Download(DownloadPlatform.appStore, appStoreUrl),
    Download(DownloadPlatform.googlePlay, googlePlayUrl),
    Download(DownloadPlatform.macOS, macOSUrl),
    Download(DownloadPlatform.windows, windowsUrl),
    Download(DownloadPlatform.linux, linuxUrl),
  ];

  /// Whether any download is still on its way.
  bool get hasPendingDownloads =>
      downloads.any((download) => !download.isAvailable);

  /// An absolute URL on this site, for canonical and social metadata.
  Uri resolve(String path) => siteUrl.resolve(path);
}

/// The configuration the published site is built with.
///
/// To put a download live, give its URL here and rebuild.
final siteConfig = SiteConfig(
  siteUrl: Uri.parse('https://openbudget.app/'),
  webAppUrl: Uri.parse('https://app.openbudget.app'),
  sourceUrl: Uri.parse('https://github.com/openbudgetfun/openbudget'),
);

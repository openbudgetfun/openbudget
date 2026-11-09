import 'package:html/dom.dart';
import 'package:jaspr/server.dart' hide Document;
import 'package:jaspr_test/server_test.dart';
import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/site.dart';

void main() {
  setUpAll(Jaspr.initializeApp);

  group('download stamps', () {
    testServer('are all "coming soon" while no download has a URL', (
      tester,
    ) async {
      final page = await _render(tester, _config());

      final stamps = page.querySelectorAll('.stamps .stamp');
      expect(stamps, hasLength(DownloadPlatform.values.length));
      for (final stamp in stamps) {
        expect(stamp.localName, 'span');
        expect(stamp.classes, contains('is-soon'));
        expect(stamp.attributes, isNot(contains('href')));
        expect(stamp.querySelector('.stamp-note')!.text, 'Coming soon');
      }
      expect(
        page.querySelector('.downloads-label')!.text,
        'Apps for every desk are on their way',
      );
      expect(_questions(page), contains(_appsQuestion));
    });

    testServer('turn into a link when the config gives a URL', (tester) async {
      final appStore = Uri.parse('https://apps.example.test/openbudget');
      final page = await _render(tester, _config(appStoreUrl: appStore));

      final live = page.querySelector('[data-platform="appStore"]')!;
      expect(live.localName, 'a');
      expect(live.attributes['href'], appStore.toString());
      expect(live.classes, isNot(contains('is-soon')));
      expect(live.querySelector('.stamp-note')!.text, 'Download for');
      expect(live.querySelector('.stamp-name')!.text, 'App Store');

      final soon = page.querySelectorAll('.stamp.is-soon');
      expect(
        soon.map((stamp) => stamp.attributes['data-platform']),
        ['googlePlay', 'macOS', 'windows', 'linux'],
      );
      expect(soon.every((stamp) => stamp.localName == 'span'), isTrue);
    });

    testServer('drop the "on their way" copy once every download is live', (
      tester,
    ) async {
      final page = await _render(
        tester,
        _config(
          appStoreUrl: Uri.parse('https://apps.example.test/openbudget'),
          googlePlayUrl: Uri.parse('https://play.example.test/openbudget'),
          macOSUrl: Uri.parse('https://example.test/OpenBudget.dmg'),
          windowsUrl: Uri.parse('https://example.test/OpenBudget.msix'),
          linuxUrl: Uri.parse('https://example.test/OpenBudget.AppImage'),
        ),
      );

      final stamps = page.querySelectorAll('.stamps .stamp');
      expect(stamps.every((stamp) => stamp.localName == 'a'), isTrue);
      expect(page.querySelectorAll('.is-soon'), isEmpty);
      expect(page.querySelector('.downloads-label')!.text, 'Get the app');
      expect(page.body!.text, isNot(contains('Coming soon')));
      expect(_questions(page), isNot(contains(_appsQuestion)));
    });
  });
}

const _appsQuestion = 'When are the phone and desktop apps coming?';

SiteConfig _config({
  Uri? appStoreUrl,
  Uri? googlePlayUrl,
  Uri? macOSUrl,
  Uri? windowsUrl,
  Uri? linuxUrl,
}) => SiteConfig(
  siteUrl: Uri.parse('https://example.test/'),
  webAppUrl: Uri.parse('https://app.example.test'),
  sourceUrl: Uri.parse('https://source.example.test'),
  appStoreUrl: appStoreUrl,
  googlePlayUrl: googlePlayUrl,
  macOSUrl: macOSUrl,
  windowsUrl: windowsUrl,
  linuxUrl: linuxUrl,
);

Future<Document> _render(ServerTester tester, SiteConfig config) async {
  tester.pumpComponent(OpenBudgetSite(config: config));
  final response = await tester.request('/');
  expect(response.statusCode, 200);
  return response.document!;
}

List<String> _questions(Document page) => [
  for (final question in page.querySelectorAll('.faq-question'))
    question.text.trim(),
];

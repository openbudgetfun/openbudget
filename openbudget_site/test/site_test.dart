import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:jaspr/server.dart' hide Document;
import 'package:jaspr_test/server_test.dart';
import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/demo_budget.dart';
import 'package:openbudget_site/src/site.dart';

void main() {
  setUpAll(Jaspr.initializeApp);

  group('home page', () {
    testServer('describes itself for search and social cards', (
      tester,
    ) async {
      final page = await _render(tester, siteConfig, '/');

      expect(
        page.querySelector('title')!.text,
        'OpenBudget: envelope budgeting across currencies',
      );
      expect(_attribute(page, 'link[rel="canonical"]', 'href'), _site);
      expect(_meta(page, 'og:url'), _site);
      expect(_meta(page, 'og:image'), 'https://openbudget.app/og.png');
      expect(
        _attribute(page, 'meta[name="twitter:image"]', 'content'),
        'https://openbudget.app/og.png',
      );
      expect(_attribute(page, 'link[rel="icon"]', 'href'), '/favicon.svg');
      expect(page.querySelector('meta[name="robots"]'), isNull);

      final structured = page.querySelector(
        'script[type="application/ld+json"]',
      );
      final data = jsonDecode(structured!.text) as Map<String, Object?>;
      expect(data['@type'], 'SoftwareApplication');
      expect(
        (data['offers']! as List<Object?>).cast<Map<String, Object?>>().map(
          (offer) => offer['price'],
        ),
        ['0', '20'],
      );
    });

    testServer('sends every web app link to the configured app', (
      tester,
    ) async {
      final config = SiteConfig(
        siteUrl: Uri.parse('https://example.test/'),
        webAppUrl: Uri.parse('https://app.example.test'),
        sourceUrl: Uri.parse('https://source.example.test/openbudget'),
      );
      final page = await _render(tester, config, '/');

      final primary = page.querySelector('.hero .cta-row a.button-ink')!;
      expect(primary.text.trim(), 'Open the web app');
      expect(primary.attributes['href'], 'https://app.example.test');
      expect(
        page.querySelector('.masthead-cta')!.attributes['href'],
        'https://app.example.test',
      );
      for (final link in page.querySelectorAll('a')) {
        if (link.text.trim() == 'Open the web app') {
          expect(link.attributes['href'], 'https://app.example.test');
        }
      }
      expect(
        page.querySelectorAll(
          'a[href="https://source.example.test/openbudget"]',
        ),
        isNotEmpty,
      );
      expect(
        _attribute(page, 'link[rel="canonical"]', 'href'),
        'https://example.test/',
      );
    });

    testServer('renders the envelope desk with its starting budget', (
      tester,
    ) async {
      final page = await _render(tester, siteConfig, '/');
      final usd = demoCurrencies.first;

      expect(
        page.querySelector('[data-ready]')!.text,
        usd.format(usd.readyToAssign),
      );
      final envelopes = page.querySelectorAll('[data-envelope]');
      expect(
        envelopes.map((envelope) => envelope.attributes['data-envelope']),
        demoEnvelopes.map((envelope) => envelope.id),
      );
      for (final (index, envelope) in envelopes.indexed) {
        final input = envelope.querySelector('input[type="range"]')!;
        expect(input.attributes['max'], '${usd.targets[index]}');
        expect(input.attributes['value'], '${usd.start[index]}');
        expect(input.attributes['step'], '${usd.step}');
        expect(
          envelope.attributes.containsKey('data-sealed'),
          usd.start[index] == usd.targets[index],
        );
      }
      expect(
        page
            .querySelectorAll('input[name="currency"]')
            .map(
              (input) => input.attributes['value'],
            ),
        demoCurrencies.map((currency) => currency.code),
      );

      final data = jsonDecode(page.querySelector('#desk-data')!.text);
      expect(data, isA<Map<String, Object?>>());
    });

    testServer('loads the script and the stylesheet the desk needs', (
      tester,
    ) async {
      final page = await _render(tester, siteConfig, '/');

      expect(
        _attribute(page, 'link[rel="stylesheet"]', 'href'),
        '/styles.css',
      );
      expect(_attribute(page, 'script[src]', 'src'), '/site.js');
    });
  });

  group('not-found page', () {
    testServer('is kept out of search results', (tester) async {
      final page = await _render(tester, siteConfig, notFoundRoute);

      expect(
        page.querySelector('title')!.text,
        'Nothing in this envelope | OpenBudget',
      );
      expect(_attribute(page, 'meta[name="robots"]', 'content'), 'noindex');
      expect(page.querySelector('link[rel="canonical"]'), isNull);
      expect(page.querySelector('h1')!.text, 'Nothing in this envelope.');
      expect(page.querySelector('#desk-data'), isNull);
      expect(
        page.querySelectorAll('a').map((link) => link.attributes['href']),
        containsAll(['/', siteConfig.webAppUrl.toString()]),
      );
    });
  });

  test('the favicon is the small mark from brand/', () {
    expect(
      File('web/favicon.svg').readAsStringSync(),
      File('../brand/mark-small.svg').readAsStringSync(),
    );
  });
}

const _site = 'https://openbudget.app/';

Future<Document> _render(
  ServerTester tester,
  SiteConfig config,
  String path,
) async {
  tester.pumpComponent(OpenBudgetSite(config: config));
  final response = await tester.request(path);
  expect(response.statusCode, 200);
  return response.document!;
}

String? _attribute(Document page, String selector, String name) =>
    page.querySelector(selector)?.attributes[name];

String? _meta(Document page, String property) =>
    _attribute(page, 'meta[property="$property"]', 'content');

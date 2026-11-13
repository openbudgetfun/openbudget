import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/pages/home_page.dart';
import 'package:openbudget_site/src/pages/not_found_page.dart';

/// The route `jaspr build` saves as the not-found page.
const notFoundRoute = '/404.html';

/// The whole site: one document whose body depends on the requested page.
///
/// It builds asynchronously so a static build can queue the not-found page
/// before `/` finishes rendering: `jaspr build` stops generating once its
/// queue is empty, so an unawaited request would race the first response.
final class OpenBudgetSite extends AsyncStatelessComponent {
  const OpenBudgetSite({required this.config, super.key});

  /// Where the site's links point.
  final SiteConfig config;

  @override
  Future<Component> build(BuildContext context) async {
    final isNotFound = context.url == notFoundRoute;
    if (!isNotFound && kGenerateMode) {
      // Static builds start from `/`; ask for the not-found page as well.
      await ServerApp.requestRouteGeneration(notFoundRoute);
    }
    final page = isNotFound ? _notFoundMeta : _homeMeta;
    final pageUrl = config.resolve(isNotFound ? notFoundRoute : '/').toString();
    final imageUrl = config.resolve('/og.png').toString();

    return Document(
      lang: 'en',
      title: page.title,
      meta: {
        'description': page.description,
        'color-scheme': 'light dark',
        if (isNotFound) 'robots': 'noindex',
        'twitter:card': 'summary_large_image',
        'twitter:title': page.title,
        'twitter:description': page.description,
        'twitter:image': imageUrl,
        'twitter:image:alt': _imageAlt,
      },
      head: [
        // Lets the stylesheet tell a scripted page from a static one before
        // anything paints.
        const script(content: "document.documentElement.classList.add('js')"),
        if (!isNotFound) link(rel: 'canonical', href: pageUrl),
        _property('og:type', 'website'),
        _property('og:site_name', 'OpenBudget'),
        _property('og:title', page.title),
        _property('og:description', page.description),
        _property('og:url', pageUrl),
        _property('og:image', imageUrl),
        _property('og:image:width', '1200'),
        _property('og:image:height', '630'),
        _property('og:image:alt', _imageAlt),
        _themeColour('#FCF8EF', '(prefers-color-scheme: light)'),
        _themeColour('#1D2131', '(prefers-color-scheme: dark)'),
        const link(rel: 'icon', href: '/favicon.svg', type: 'image/svg+xml'),
        const link(rel: 'apple-touch-icon', href: '/apple-touch-icon.png'),
        for (final font in _preloadedFonts)
          link(
            rel: 'preload',
            href: font,
            as: 'font',
            type: 'font/woff2',
            attributes: const {'crossorigin': ''},
          ),
        const link(rel: 'stylesheet', href: '/styles.css'),
        if (!isNotFound) ...[
          const script(src: '/site.js', defer: true),
          script(
            content: _structuredData(config),
            attributes: const {'type': 'application/ld+json'},
          ),
        ],
      ],
      body: isNotFound
          ? NotFoundPage(config: config)
          : HomePage(config: config),
    );
  }
}

typedef _PageMeta = ({String title, String description});

const _PageMeta _homeMeta = (
  title: 'OpenBudget: envelope budgeting across currencies',
  description:
      'Put every dollar, pound, euro and naira in an envelope. OpenBudget '
      'budgets across the currencies you hold, keeps your household and '
      'business books, and guides your taxes in the UK, US, Nigeria and '
      'Germany. Free to start and open source.',
);

const _PageMeta _notFoundMeta = (
  title: 'Nothing in this envelope | OpenBudget',
  description: 'This page does not exist. Head back to OpenBudget.',
);

const _imageAlt =
    'The OpenBudget mark, three paper envelopes filled with blue pencil and '
    'the tallest sealed with yellow wax, beside the words "Put every dollar '
    'in an envelope."';

/// The fonts the first screen needs, fetched before the stylesheet asks.
const _preloadedFonts = [
  '/fonts/skribble-gentle-extrabold.woff2',
  '/fonts/skribble-linear-gentle-regular.woff2',
];

Component _property(String property, String content) => Component.element(
  tag: 'meta',
  attributes: {'property': property, 'content': content},
);

Component _themeColour(String colour, String media) => Component.element(
  tag: 'meta',
  attributes: {'name': 'theme-color', 'content': colour, 'media': media},
);

/// Schema.org data so search engines can describe the app and its prices.
String _structuredData(SiteConfig config) => jsonEncode({
  '@context': 'https://schema.org',
  '@type': 'SoftwareApplication',
  'name': 'OpenBudget',
  'applicationCategory': 'FinanceApplication',
  'operatingSystem': 'Web',
  'url': config.siteUrl.toString(),
  'description': _homeMeta.description,
  'offers': [
    {'@type': 'Offer', 'name': 'Free', 'price': '0', 'priceCurrency': 'USD'},
    {
      '@type': 'Offer',
      'name': 'OpenBudget Plus',
      'price': '20',
      'priceCurrency': 'USD',
    },
  ],
}).replaceAll('</', r'<\/');

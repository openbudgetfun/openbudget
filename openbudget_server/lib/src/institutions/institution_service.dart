import 'dart:math' as math;

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

class InstitutionService {
  static final _log = ObLogger('InstitutionService');

  static final Set<String> _europeLocationCodes = {
    'AT',
    'BE',
    'BG',
    'CH',
    'CY',
    'CZ',
    'DE',
    'DK',
    'EE',
    'ES',
    'FI',
    'FR',
    'GB',
    'GR',
    'HR',
    'HU',
    'IE',
    'IS',
    'IT',
    'LT',
    'LU',
    'LV',
    'MT',
    'NL',
    'NO',
    'PL',
    'PT',
    'RO',
    'SE',
    'SI',
    'SK',
    'EU',
  };

  static Future<void> ensureCatalogSeeded(Session session) async {
    _log.info(
      'Seeding institution catalog with ${_seedInstitutions.length} entries.',
    );

    final slugs = _seedInstitutions.map((seed) => seed.slug).toSet();
    final existingInstitutions = await Institution.db.find(
      session,
      where: (t) => t.slug.inSet(slugs),
    );
    final institutionBySlug = <String, Institution>{
      for (final institution in existingInstitutions)
        institution.slug: institution,
    };

    final institutionIdsBySlug = <String, UuidValue>{};

    for (final seed in _seedInstitutions) {
      final existing = institutionBySlug[seed.slug];
      final persisted = existing == null
          ? await Institution.db.insertRow(
              session,
              Institution(
                slug: seed.slug,
                name: seed.name,
                website: seed.website,
                plaidInstitutionId: seed.plaidInstitutionId,
                isDigitalBank: seed.isDigitalBank,
              ),
            )
          : await _updateInstitutionIfChanged(session, existing, seed);

      final institutionId = persisted.id;
      if (institutionId == null) {
        throw StateError('Institution id missing for ${seed.slug}.');
      }
      institutionIdsBySlug[seed.slug] = institutionId;
    }

    final institutionIds = institutionIdsBySlug.values.toSet();
    final existingLocations = institutionIds.isEmpty
        ? const <InstitutionLocation>[]
        : await InstitutionLocation.db.find(
            session,
            where: (t) => t.institutionId.inSet(institutionIds),
          );

    final locationByKey = <String, InstitutionLocation>{
      for (final location in existingLocations)
        '${location.institutionId}:${location.locationCode}': location,
    };

    for (final seed in _seedInstitutions) {
      final institutionId = institutionIdsBySlug[seed.slug];
      if (institutionId == null) continue;

      final locationCodes = <String>{
        ...seed.locations,
        ...seed.popularRanks.keys,
      };

      for (final rawCode in locationCodes) {
        final code = normalizeLocationCode(rawCode);
        if (code == null) continue;

        final key = '$institutionId:$code';
        final existing = locationByKey[key];
        final rank = seed.popularRanks[code];
        final isPopular = rank != null;

        if (existing == null) {
          final created = await InstitutionLocation.db.insertRow(
            session,
            InstitutionLocation(
              institutionId: institutionId,
              locationCode: code,
              isPopular: isPopular,
              popularityRank: rank,
            ),
          );
          locationByKey[key] = created;
          continue;
        }

        if (existing.isPopular != isPopular ||
            existing.popularityRank != rank) {
          final updated = await InstitutionLocation.db.updateRow(
            session,
            existing.copyWith(isPopular: isPopular, popularityRank: rank),
          );
          locationByKey[key] = updated;
        }
      }
    }
  }

  static Future<List<Institution>> listCatalog(
    Session session, {
    String? locationCode,
  }) async {
    await ensureCatalogSeeded(session);

    final normalizedLocation = normalizeLocationCode(locationCode) ?? 'US';
    final institutions = await Institution.db.find(
      session,
      orderBy: (t) => t.name,
    );
    if (institutions.isEmpty) return const [];

    final markers = _locationMarkers(normalizedLocation);
    final locations = await InstitutionLocation.db.find(
      session,
      where: (t) => t.locationCode.inSet(markers),
    );

    final metaByInstitutionId = <UuidValue, _LocationMeta>{};
    for (final location in locations) {
      final current = metaByInstitutionId[location.institutionId];
      final rank = location.popularityRank ?? 9999;
      if (current == null) {
        metaByInstitutionId[location.institutionId] = _LocationMeta(
          isPopular: location.isPopular,
          popularityRank: rank,
        );
        continue;
      }

      metaByInstitutionId[location.institutionId] = _LocationMeta(
        isPopular: current.isPopular || location.isPopular,
        popularityRank: math.min(current.popularityRank, rank),
      );
    }

    final sorted = [...institutions]
      ..sort((a, b) {
        final aId = a.id;
        final bId = b.id;

        final aMeta = aId == null ? null : metaByInstitutionId[aId];
        final bMeta = bId == null ? null : metaByInstitutionId[bId];

        final aPopular = aMeta?.isPopular ?? false;
        final bPopular = bMeta?.isPopular ?? false;
        if (aPopular != bPopular) return aPopular ? -1 : 1;

        if (aPopular && bPopular) {
          final byRank = aMeta!.popularityRank.compareTo(bMeta!.popularityRank);
          if (byRank != 0) return byRank;
        }

        if (a.isDigitalBank != b.isDigitalBank) {
          return a.isDigitalBank ? -1 : 1;
        }

        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return sorted;
  }

  static Future<UuidValue?> resolveInstitutionId(
    Session session, {
    String? plaidInstitutionId,
    String? institutionName,
  }) async {
    await ensureCatalogSeeded(session);

    final normalizedPlaidId = plaidInstitutionId?.trim();
    if (normalizedPlaidId != null && normalizedPlaidId.isNotEmpty) {
      final byPlaidId = await Institution.db.findFirstRow(
        session,
        where: (t) => t.plaidInstitutionId.equals(normalizedPlaidId),
      );
      if (byPlaidId?.id != null) return byPlaidId!.id;
    }

    final normalizedName = institutionName?.trim();
    if (normalizedName == null || normalizedName.isEmpty) return null;

    final exact = await Institution.db.findFirstRow(
      session,
      where: (t) => t.name.equals(normalizedName),
    );
    if (exact?.id != null) return exact!.id;

    final slug = _slugify(normalizedName);
    final bySlug = await Institution.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(slug),
    );
    return bySlug?.id;
  }

  static String? normalizeLocationCode(String? locationCode) {
    final normalized = locationCode?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }

  static Set<String> _locationMarkers(String normalizedLocation) {
    final markers = <String>{normalizedLocation, 'GLOBAL'};
    if (_europeLocationCodes.contains(normalizedLocation)) {
      markers.add('EU');
    }
    return markers;
  }

  static Future<Institution> _updateInstitutionIfChanged(
    Session session,
    Institution existing,
    _SeedInstitution seed,
  ) async {
    if (existing.name == seed.name &&
        existing.website == seed.website &&
        existing.plaidInstitutionId == seed.plaidInstitutionId &&
        existing.isDigitalBank == seed.isDigitalBank) {
      return existing;
    }

    return Institution.db.updateRow(
      session,
      existing.copyWith(
        name: seed.name,
        website: seed.website,
        plaidInstitutionId: seed.plaidInstitutionId,
        isDigitalBank: seed.isDigitalBank,
      ),
    );
  }

  static String _slugify(String raw) {
    final lower = raw.toLowerCase();
    final compact = lower.replaceAll(RegExp('[^a-z0-9]+'), '-');
    return compact.replaceAll(RegExp(r'^-+|-+$'), '');
  }
}

class _LocationMeta {
  const _LocationMeta({required this.isPopular, required this.popularityRank});

  final bool isPopular;
  final int popularityRank;
}

class _SeedInstitution {
  const _SeedInstitution({
    required this.slug,
    required this.name,
    required this.website,
    required this.locations,
    this.isDigitalBank = false,
    this.plaidInstitutionId,
    this.popularRanks = const <String, int>{},
  });

  final String slug;
  final String name;
  final String website;
  final List<String> locations;
  final bool isDigitalBank;
  final String? plaidInstitutionId;
  final Map<String, int> popularRanks;
}

const _institutionCatalog = <_SeedInstitution>[
  _SeedInstitution(
    slug: 'jpmorgan-chase',
    name: 'JPMorgan Chase',
    website: 'chase.com',
    locations: ['US'],
    plaidInstitutionId: 'ins_56',
    popularRanks: {'US': 1, 'GLOBAL': 20},
  ),
  _SeedInstitution(
    slug: 'bank-of-america',
    name: 'Bank of America',
    website: 'bankofamerica.com',
    locations: ['US'],
    plaidInstitutionId: 'ins_3',
    popularRanks: {'US': 2},
  ),
  _SeedInstitution(
    slug: 'wells-fargo',
    name: 'Wells Fargo',
    website: 'wellsfargo.com',
    locations: ['US'],
    plaidInstitutionId: 'ins_127287',
    popularRanks: {'US': 3},
  ),
  _SeedInstitution(
    slug: 'citi',
    name: 'Citi',
    website: 'citi.com',
    locations: ['US'],
    plaidInstitutionId: 'ins_10',
    popularRanks: {'US': 4},
  ),
  _SeedInstitution(
    slug: 'capital-one',
    name: 'Capital One',
    website: 'capitalone.com',
    locations: ['US'],
    plaidInstitutionId: 'ins_128026',
    popularRanks: {'US': 5},
  ),
  _SeedInstitution(
    slug: 'american-express',
    name: 'American Express',
    website: 'americanexpress.com',
    locations: ['US'],
    plaidInstitutionId: 'ins_109508',
    popularRanks: {'US': 6},
  ),
  _SeedInstitution(
    slug: 'us-bank',
    name: 'U.S. Bank',
    website: 'usbank.com',
    locations: ['US'],
    popularRanks: {'US': 7},
  ),
  _SeedInstitution(
    slug: 'pnc-bank',
    name: 'PNC Bank',
    website: 'pnc.com',
    locations: ['US'],
    popularRanks: {'US': 8},
  ),
  _SeedInstitution(
    slug: 'truist',
    name: 'Truist',
    website: 'truist.com',
    locations: ['US'],
    popularRanks: {'US': 9},
  ),
  _SeedInstitution(
    slug: 'td-bank-us',
    name: 'TD Bank (US)',
    website: 'td.com',
    locations: ['US', 'CA'],
    popularRanks: {'US': 10},
  ),
  _SeedInstitution(
    slug: 'discover-bank',
    name: 'Discover Bank',
    website: 'discover.com',
    locations: ['US'],
  ),
  _SeedInstitution(
    slug: 'ally-bank',
    name: 'Ally Bank',
    website: 'ally.com',
    locations: ['US'],
  ),
  _SeedInstitution(
    slug: 'rbc',
    name: 'RBC Royal Bank',
    website: 'rbcroyalbank.com',
    locations: ['CA'],
    popularRanks: {'CA': 1},
  ),
  _SeedInstitution(
    slug: 'scotiabank',
    name: 'Scotiabank',
    website: 'scotiabank.com',
    locations: ['CA'],
    popularRanks: {'CA': 2},
  ),
  _SeedInstitution(
    slug: 'bmo',
    name: 'BMO',
    website: 'bmo.com',
    locations: ['CA'],
    popularRanks: {'CA': 3},
  ),
  _SeedInstitution(
    slug: 'cibc',
    name: 'CIBC',
    website: 'cibc.com',
    locations: ['CA'],
    popularRanks: {'CA': 4},
  ),
  _SeedInstitution(
    slug: 'national-bank-of-canada',
    name: 'National Bank of Canada',
    website: 'nbc.ca',
    locations: ['CA'],
    popularRanks: {'CA': 5},
  ),
  _SeedInstitution(
    slug: 'hsbc',
    name: 'HSBC',
    website: 'hsbc.com',
    locations: ['GB', 'EU', 'HK', 'SG', 'AE'],
    popularRanks: {'GB': 8, 'EU': 10},
  ),
  _SeedInstitution(
    slug: 'barclays',
    name: 'Barclays',
    website: 'barclays.co.uk',
    locations: ['GB', 'EU'],
    popularRanks: {'GB': 7},
  ),
  _SeedInstitution(
    slug: 'lloyds-bank',
    name: 'Lloyds Bank',
    website: 'lloydsbank.com',
    locations: ['GB'],
    popularRanks: {'GB': 5},
  ),
  _SeedInstitution(
    slug: 'natwest',
    name: 'NatWest',
    website: 'natwest.com',
    locations: ['GB'],
    popularRanks: {'GB': 6},
  ),
  _SeedInstitution(
    slug: 'santander-uk',
    name: 'Santander UK',
    website: 'santander.co.uk',
    locations: ['GB'],
    popularRanks: {'GB': 9},
  ),
  _SeedInstitution(
    slug: 'monzo',
    name: 'Monzo',
    website: 'monzo.com',
    locations: ['GB', 'EU'],
    isDigitalBank: true,
    popularRanks: {'GB': 1, 'EU': 1},
  ),
  _SeedInstitution(
    slug: 'revolut',
    name: 'Revolut',
    website: 'revolut.com',
    locations: ['GB', 'EU'],
    isDigitalBank: true,
    popularRanks: {'GB': 2, 'EU': 2},
  ),
  _SeedInstitution(
    slug: 'wise',
    name: 'Wise',
    website: 'wise.com',
    locations: ['GB', 'EU', 'US', 'SG', 'AU'],
    isDigitalBank: true,
    popularRanks: {'GB': 3, 'EU': 3},
  ),
  _SeedInstitution(
    slug: 'starling-bank',
    name: 'Starling Bank',
    website: 'starlingbank.com',
    locations: ['GB'],
    isDigitalBank: true,
    popularRanks: {'GB': 4, 'EU': 4},
  ),
  _SeedInstitution(
    slug: 'n26',
    name: 'N26',
    website: 'n26.com',
    locations: ['DE', 'EU'],
    isDigitalBank: true,
    popularRanks: {'EU': 5},
  ),
  _SeedInstitution(
    slug: 'bunq',
    name: 'bunq',
    website: 'bunq.com',
    locations: ['NL', 'EU'],
    isDigitalBank: true,
    popularRanks: {'EU': 6},
  ),
  _SeedInstitution(
    slug: 'ing',
    name: 'ING',
    website: 'ing.com',
    locations: ['NL', 'BE', 'DE', 'EU'],
    popularRanks: {'EU': 7},
  ),
  _SeedInstitution(
    slug: 'bnp-paribas',
    name: 'BNP Paribas',
    website: 'bnpparibas.com',
    locations: ['FR', 'EU'],
    popularRanks: {'EU': 8},
  ),
  _SeedInstitution(
    slug: 'societe-generale',
    name: 'Societe Generale',
    website: 'societegenerale.com',
    locations: ['FR', 'EU'],
  ),
  _SeedInstitution(
    slug: 'credit-agricole',
    name: 'Credit Agricole',
    website: 'credit-agricole.com',
    locations: ['FR', 'EU'],
  ),
  _SeedInstitution(
    slug: 'deutsche-bank',
    name: 'Deutsche Bank',
    website: 'db.com',
    locations: ['DE', 'EU'],
    popularRanks: {'EU': 9},
  ),
  _SeedInstitution(
    slug: 'commerzbank',
    name: 'Commerzbank',
    website: 'commerzbank.com',
    locations: ['DE', 'EU'],
  ),
  _SeedInstitution(
    slug: 'unicredit',
    name: 'UniCredit',
    website: 'unicreditgroup.eu',
    locations: ['IT', 'DE', 'EU'],
  ),
  _SeedInstitution(
    slug: 'intesa-sanpaolo',
    name: 'Intesa Sanpaolo',
    website: 'intesasanpaolo.com',
    locations: ['IT', 'EU'],
  ),
  _SeedInstitution(
    slug: 'banco-santander',
    name: 'Banco Santander',
    website: 'santander.com',
    locations: ['ES', 'PT', 'EU', 'MX', 'BR'],
  ),
  _SeedInstitution(
    slug: 'bbva',
    name: 'BBVA',
    website: 'bbva.com',
    locations: ['ES', 'EU', 'MX', 'AR'],
  ),
  _SeedInstitution(
    slug: 'caixabank',
    name: 'CaixaBank',
    website: 'caixabank.com',
    locations: ['ES', 'EU'],
  ),
  _SeedInstitution(
    slug: 'abn-amro',
    name: 'ABN AMRO',
    website: 'abnamro.com',
    locations: ['NL', 'EU'],
  ),
  _SeedInstitution(
    slug: 'rabobank',
    name: 'Rabobank',
    website: 'rabobank.com',
    locations: ['NL', 'EU'],
  ),
  _SeedInstitution(
    slug: 'nordea',
    name: 'Nordea',
    website: 'nordea.com',
    locations: ['SE', 'FI', 'NO', 'DK', 'EU'],
  ),
  _SeedInstitution(
    slug: 'seb',
    name: 'SEB',
    website: 'sebgroup.com',
    locations: ['SE', 'EU'],
  ),
  _SeedInstitution(
    slug: 'swedbank',
    name: 'Swedbank',
    website: 'swedbank.se',
    locations: ['SE', 'EU'],
  ),
  _SeedInstitution(
    slug: 'danske-bank',
    name: 'Danske Bank',
    website: 'danskebank.com',
    locations: ['DK', 'EU'],
  ),
  _SeedInstitution(
    slug: 'dnb',
    name: 'DNB',
    website: 'dnb.no',
    locations: ['NO', 'EU'],
  ),
  _SeedInstitution(
    slug: 'ubs',
    name: 'UBS',
    website: 'ubs.com',
    locations: ['CH', 'EU', 'US', 'SG'],
  ),
  _SeedInstitution(
    slug: 'credit-suisse',
    name: 'Credit Suisse',
    website: 'credit-suisse.com',
    locations: ['CH', 'EU'],
  ),
  _SeedInstitution(
    slug: 'postfinance',
    name: 'PostFinance',
    website: 'postfinance.ch',
    locations: ['CH', 'EU'],
  ),
  _SeedInstitution(
    slug: 'erste-group',
    name: 'Erste Group',
    website: 'erstegroup.com',
    locations: ['AT', 'EU'],
  ),
  _SeedInstitution(
    slug: 'raiffeisen-bank-international',
    name: 'Raiffeisen Bank International',
    website: 'rbinternational.com',
    locations: ['AT', 'EU'],
  ),
  _SeedInstitution(
    slug: 'pko-bank-polski',
    name: 'PKO Bank Polski',
    website: 'pkobp.pl',
    locations: ['PL', 'EU'],
  ),
  _SeedInstitution(
    slug: 'mbank',
    name: 'mBank',
    website: 'mbank.pl',
    locations: ['PL', 'EU'],
    isDigitalBank: true,
  ),
  _SeedInstitution(
    slug: 'kbc-bank',
    name: 'KBC Bank',
    website: 'kbc.com',
    locations: ['BE', 'EU'],
  ),
  _SeedInstitution(
    slug: 'belfius',
    name: 'Belfius',
    website: 'belfius.be',
    locations: ['BE', 'EU'],
  ),
  _SeedInstitution(
    slug: 'aib',
    name: 'AIB',
    website: 'aib.ie',
    locations: ['IE', 'EU'],
  ),
  _SeedInstitution(
    slug: 'bank-of-ireland',
    name: 'Bank of Ireland',
    website: 'bankofireland.com',
    locations: ['IE', 'EU'],
  ),
  _SeedInstitution(
    slug: 'permanent-tsb',
    name: 'Permanent TSB',
    website: 'permanenttsb.ie',
    locations: ['IE', 'EU'],
  ),
  _SeedInstitution(
    slug: 'millennium-bcp',
    name: 'Millennium bcp',
    website: 'millenniumbcp.pt',
    locations: ['PT', 'EU'],
  ),
  _SeedInstitution(
    slug: 'novo-banco',
    name: 'Novo Banco',
    website: 'novobanco.pt',
    locations: ['PT', 'EU'],
  ),
  _SeedInstitution(
    slug: 'standard-chartered',
    name: 'Standard Chartered',
    website: 'sc.com',
    locations: ['GB', 'HK', 'SG', 'AE'],
  ),
  _SeedInstitution(
    slug: 'dbs-bank',
    name: 'DBS Bank',
    website: 'dbs.com',
    locations: ['SG', 'HK'],
    popularRanks: {'SG': 1},
  ),
  _SeedInstitution(
    slug: 'ocbc-bank',
    name: 'OCBC Bank',
    website: 'ocbc.com',
    locations: ['SG'],
    popularRanks: {'SG': 2},
  ),
  _SeedInstitution(
    slug: 'uob',
    name: 'UOB',
    website: 'uob.com.sg',
    locations: ['SG'],
    popularRanks: {'SG': 3},
  ),
  _SeedInstitution(
    slug: 'hang-seng-bank',
    name: 'Hang Seng Bank',
    website: 'hangseng.com',
    locations: ['HK'],
    popularRanks: {'HK': 1},
  ),
  _SeedInstitution(
    slug: 'bank-of-china-hong-kong',
    name: 'Bank of China (Hong Kong)',
    website: 'bochk.com',
    locations: ['HK'],
    popularRanks: {'HK': 2},
  ),
  _SeedInstitution(
    slug: 'hsbc-hong-kong',
    name: 'HSBC Hong Kong',
    website: 'hsbc.com.hk',
    locations: ['HK'],
    popularRanks: {'HK': 3},
  ),
  _SeedInstitution(
    slug: 'mizuho-bank',
    name: 'Mizuho Bank',
    website: 'mizuhogroup.com',
    locations: ['JP'],
    popularRanks: {'JP': 1},
  ),
  _SeedInstitution(
    slug: 'mufg-bank',
    name: 'MUFG Bank',
    website: 'mufg.jp',
    locations: ['JP'],
    popularRanks: {'JP': 2},
  ),
  _SeedInstitution(
    slug: 'smbc',
    name: 'SMBC',
    website: 'smbc.co.jp',
    locations: ['JP'],
    popularRanks: {'JP': 3},
  ),
  _SeedInstitution(
    slug: 'resona-bank',
    name: 'Resona Bank',
    website: 'resonabank.co.jp',
    locations: ['JP'],
  ),
  _SeedInstitution(
    slug: 'china-construction-bank',
    name: 'China Construction Bank',
    website: 'ccb.com',
    locations: ['CN'],
    popularRanks: {'CN': 1},
  ),
  _SeedInstitution(
    slug: 'icbc',
    name: 'Industrial and Commercial Bank of China',
    website: 'icbc.com.cn',
    locations: ['CN'],
    popularRanks: {'CN': 2},
  ),
  _SeedInstitution(
    slug: 'agricultural-bank-of-china',
    name: 'Agricultural Bank of China',
    website: 'abchina.com',
    locations: ['CN'],
    popularRanks: {'CN': 3},
  ),
  _SeedInstitution(
    slug: 'bank-of-china',
    name: 'Bank of China',
    website: 'bankofchina.com',
    locations: ['CN', 'HK'],
    popularRanks: {'CN': 4},
  ),
  _SeedInstitution(
    slug: 'china-merchants-bank',
    name: 'China Merchants Bank',
    website: 'cmbchina.com',
    locations: ['CN'],
    popularRanks: {'CN': 5},
  ),
  _SeedInstitution(
    slug: 'postal-savings-bank-of-china',
    name: 'Postal Savings Bank of China',
    website: 'psbc.com',
    locations: ['CN'],
  ),
  _SeedInstitution(
    slug: 'hdfc-bank',
    name: 'HDFC Bank',
    website: 'hdfcbank.com',
    locations: ['IN'],
    popularRanks: {'IN': 1},
  ),
  _SeedInstitution(
    slug: 'icici-bank',
    name: 'ICICI Bank',
    website: 'icicibank.com',
    locations: ['IN'],
    popularRanks: {'IN': 2},
  ),
  _SeedInstitution(
    slug: 'state-bank-of-india',
    name: 'State Bank of India',
    website: 'sbi.co.in',
    locations: ['IN'],
    popularRanks: {'IN': 3},
  ),
  _SeedInstitution(
    slug: 'axis-bank',
    name: 'Axis Bank',
    website: 'axisbank.com',
    locations: ['IN'],
    popularRanks: {'IN': 4},
  ),
  _SeedInstitution(
    slug: 'kotak-mahindra-bank',
    name: 'Kotak Mahindra Bank',
    website: 'kotak.com',
    locations: ['IN'],
    popularRanks: {'IN': 5},
  ),
  _SeedInstitution(
    slug: 'yes-bank',
    name: 'Yes Bank',
    website: 'yesbank.in',
    locations: ['IN'],
  ),
  _SeedInstitution(
    slug: 'banco-do-brasil',
    name: 'Banco do Brasil',
    website: 'bb.com.br',
    locations: ['BR'],
    popularRanks: {'BR': 1},
  ),
  _SeedInstitution(
    slug: 'itau-unibanco',
    name: 'Itau Unibanco',
    website: 'itau.com.br',
    locations: ['BR'],
    popularRanks: {'BR': 2},
  ),
  _SeedInstitution(
    slug: 'banco-bradesco',
    name: 'Banco Bradesco',
    website: 'bradesco.com.br',
    locations: ['BR'],
    popularRanks: {'BR': 3},
  ),
  _SeedInstitution(
    slug: 'caixa-economica-federal',
    name: 'Caixa Economica Federal',
    website: 'caixa.gov.br',
    locations: ['BR'],
    popularRanks: {'BR': 4},
  ),
  _SeedInstitution(
    slug: 'nubank',
    name: 'Nubank',
    website: 'nubank.com.br',
    locations: ['BR', 'MX', 'CO'],
    isDigitalBank: true,
    popularRanks: {'BR': 5},
  ),
  _SeedInstitution(
    slug: 'banco-inter',
    name: 'Banco Inter',
    website: 'bancointer.com.br',
    locations: ['BR'],
    isDigitalBank: true,
  ),
  _SeedInstitution(
    slug: 'banco-de-chile',
    name: 'Banco de Chile',
    website: 'bancochile.cl',
    locations: ['CL'],
    popularRanks: {'CL': 1},
  ),
  _SeedInstitution(
    slug: 'bancoestado',
    name: 'BancoEstado',
    website: 'bancoestado.cl',
    locations: ['CL'],
    popularRanks: {'CL': 2},
  ),
  _SeedInstitution(
    slug: 'bbva-mexico',
    name: 'BBVA Mexico',
    website: 'bbva.mx',
    locations: ['MX'],
    popularRanks: {'MX': 1},
  ),
  _SeedInstitution(
    slug: 'banorte',
    name: 'Banorte',
    website: 'banorte.com',
    locations: ['MX'],
    popularRanks: {'MX': 2},
  ),
  _SeedInstitution(
    slug: 'santander-mexico',
    name: 'Santander Mexico',
    website: 'santander.com.mx',
    locations: ['MX'],
    popularRanks: {'MX': 3},
  ),
  _SeedInstitution(
    slug: 'commonwealth-bank',
    name: 'Commonwealth Bank',
    website: 'commbank.com.au',
    locations: ['AU'],
    popularRanks: {'AU': 1},
  ),
  _SeedInstitution(
    slug: 'westpac',
    name: 'Westpac',
    website: 'westpac.com.au',
    locations: ['AU'],
    popularRanks: {'AU': 2},
  ),
  _SeedInstitution(
    slug: 'anz',
    name: 'ANZ',
    website: 'anz.com.au',
    locations: ['AU', 'NZ'],
    popularRanks: {'AU': 3, 'NZ': 1},
  ),
  _SeedInstitution(
    slug: 'nab',
    name: 'NAB',
    website: 'nab.com.au',
    locations: ['AU'],
    popularRanks: {'AU': 4},
  ),
  _SeedInstitution(
    slug: 'macquarie',
    name: 'Macquarie',
    website: 'macquarie.com',
    locations: ['AU'],
    popularRanks: {'AU': 5},
  ),
  _SeedInstitution(
    slug: 'first-national-bank-sa',
    name: 'First National Bank (South Africa)',
    website: 'fnb.co.za',
    locations: ['ZA'],
    popularRanks: {'ZA': 1},
  ),
  _SeedInstitution(
    slug: 'standard-bank',
    name: 'Standard Bank',
    website: 'standardbank.co.za',
    locations: ['ZA'],
    popularRanks: {'ZA': 2},
  ),
  _SeedInstitution(
    slug: 'absa',
    name: 'Absa',
    website: 'absa.co.za',
    locations: ['ZA'],
    popularRanks: {'ZA': 3},
  ),
  _SeedInstitution(
    slug: 'nedbank',
    name: 'Nedbank',
    website: 'nedbank.co.za',
    locations: ['ZA'],
  ),
  _SeedInstitution(
    slug: 'firstbank-nigeria',
    name: 'FirstBank Nigeria',
    website: 'firstbanknigeria.com',
    locations: ['NG'],
    popularRanks: {'NG': 1},
  ),
  _SeedInstitution(
    slug: 'gtbank',
    name: 'Guaranty Trust Bank',
    website: 'gtbank.com',
    locations: ['NG'],
    popularRanks: {'NG': 2},
  ),
  _SeedInstitution(
    slug: 'access-bank',
    name: 'Access Bank',
    website: 'accessbankplc.com',
    locations: ['NG'],
    popularRanks: {'NG': 3},
  ),
  _SeedInstitution(
    slug: 'equity-bank',
    name: 'Equity Bank',
    website: 'equitygroupholdings.com',
    locations: ['KE'],
    popularRanks: {'KE': 1},
  ),
  _SeedInstitution(
    slug: 'kcb-bank',
    name: 'KCB Bank',
    website: 'kcbgroup.com',
    locations: ['KE'],
    popularRanks: {'KE': 2},
  ),
  _SeedInstitution(
    slug: 'emirates-nbd',
    name: 'Emirates NBD',
    website: 'emiratesnbd.com',
    locations: ['AE'],
    popularRanks: {'AE': 1},
  ),
  _SeedInstitution(
    slug: 'first-abu-dhabi-bank',
    name: 'First Abu Dhabi Bank',
    website: 'bankfab.com',
    locations: ['AE'],
    popularRanks: {'AE': 2},
  ),
  _SeedInstitution(
    slug: 'riyad-bank',
    name: 'Riyad Bank',
    website: 'riyadbank.com',
    locations: ['SA'],
    popularRanks: {'SA': 1},
  ),
  _SeedInstitution(
    slug: 'al-rajhi-bank',
    name: 'Al Rajhi Bank',
    website: 'alrajhibank.com.sa',
    locations: ['SA'],
    popularRanks: {'SA': 2},
  ),
  _SeedInstitution(
    slug: 'bank-leumi',
    name: 'Bank Leumi',
    website: 'leumi.co.il',
    locations: ['IL'],
  ),
  _SeedInstitution(
    slug: 'hapoalim',
    name: 'Bank Hapoalim',
    website: 'bankhapoalim.co.il',
    locations: ['IL'],
  ),
  _SeedInstitution(
    slug: 'garanti-bbva',
    name: 'Garanti BBVA',
    website: 'garantibbva.com.tr',
    locations: ['TR'],
  ),
  _SeedInstitution(
    slug: 'isbank',
    name: 'Isbank',
    website: 'isbank.com.tr',
    locations: ['TR'],
  ),
  _SeedInstitution(
    slug: 'alpha-bank',
    name: 'Alpha Bank',
    website: 'alphabank.gr',
    locations: ['GR', 'EU'],
  ),
  _SeedInstitution(
    slug: 'eurobank',
    name: 'Eurobank',
    website: 'eurobank.gr',
    locations: ['GR', 'EU'],
  ),
  _SeedInstitution(
    slug: 'bank-pekao',
    name: 'Bank Pekao',
    website: 'pekao.com.pl',
    locations: ['PL', 'EU'],
  ),
  _SeedInstitution(
    slug: 'otp-bank',
    name: 'OTP Bank',
    website: 'otpbank.hu',
    locations: ['HU', 'EU'],
  ),
  _SeedInstitution(
    slug: 'bankia',
    name: 'Bankia',
    website: 'bankia.es',
    locations: ['ES', 'EU'],
  ),
  _SeedInstitution(
    slug: 'sabadell',
    name: 'Banco Sabadell',
    website: 'bancsabadell.com',
    locations: ['ES', 'EU'],
  ),
  _SeedInstitution(
    slug: 'new-zealand-anz',
    name: 'ANZ New Zealand',
    website: 'anz.co.nz',
    locations: ['NZ'],
    popularRanks: {'NZ': 2},
  ),
  _SeedInstitution(
    slug: 'asb-bank',
    name: 'ASB Bank',
    website: 'asb.co.nz',
    locations: ['NZ'],
    popularRanks: {'NZ': 3},
  ),
  _SeedInstitution(
    slug: 'kiwibank',
    name: 'Kiwibank',
    website: 'kiwibank.co.nz',
    locations: ['NZ'],
    popularRanks: {'NZ': 4},
  ),
  _SeedInstitution(
    slug: 'rabobank-new-zealand',
    name: 'Rabobank New Zealand',
    website: 'rabobank.co.nz',
    locations: ['NZ'],
    popularRanks: {'NZ': 5},
  ),
  _SeedInstitution(
    slug: 'bank-mandiri',
    name: 'Bank Mandiri',
    website: 'bankmandiri.co.id',
    locations: ['ID'],
    popularRanks: {'ID': 1},
  ),
  _SeedInstitution(
    slug: 'bca',
    name: 'Bank Central Asia (BCA)',
    website: 'bca.co.id',
    locations: ['ID'],
    popularRanks: {'ID': 2},
  ),
  _SeedInstitution(
    slug: 'maybank',
    name: 'Maybank',
    website: 'maybank.com',
    locations: ['MY', 'SG'],
    popularRanks: {'MY': 1},
  ),
  _SeedInstitution(
    slug: 'cimb-bank',
    name: 'CIMB Bank',
    website: 'cimb.com',
    locations: ['MY', 'SG'],
    popularRanks: {'MY': 2},
  ),
  _SeedInstitution(
    slug: 'bangkok-bank',
    name: 'Bangkok Bank',
    website: 'bangkokbank.com',
    locations: ['TH'],
    popularRanks: {'TH': 1},
  ),
  _SeedInstitution(
    slug: 'kasikornbank',
    name: 'Kasikornbank',
    website: 'kasikornbank.com',
    locations: ['TH'],
    popularRanks: {'TH': 2},
  ),
];

final _seedInstitutions = _institutionCatalog.take(100).toList(growable: false);

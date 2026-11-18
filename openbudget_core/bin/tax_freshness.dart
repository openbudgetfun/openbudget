import 'dart:io';

import 'package:openbudget_core/src/countries/country_info.dart';
import 'package:openbudget_core/src/countries/tax_freshness.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_rules.dart';

const _usage =
    'Lists the tax reference data due for a re-check '
    '(docs/tax-jurisdictions.md, section 7).\n'
    '\n'
    'Usage: dart run openbudget_core:tax_freshness '
    '[--as-of YYYY-MM-DD] [--json]\n'
    '\n'
    '  --as-of YYYY-MM-DD  Report as if run on that day (default: today).\n'
    '  --json              Machine-readable output for automation.\n'
    '  -h, --help          Show this help.\n'
    '\n'
    'The exit code is 0 whenever the report is produced: overdue data is a '
    'work queue, not a build failure.';

/// The command line over the freshness logic in `tax_freshness.dart`. It
/// reads the country dataset and every rule pack's caveats, lists each
/// `recheckBy` date on or before the as-of day with the overdue count, and
/// exits 0 either way.
void main(List<String> args) {
  var asOf = todayAsCivilDate();
  var json = false;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--json':
        json = true;
      case '--help' || '-h':
        stdout.writeln(_usage);
        return;
      case '--as-of':
        if (i + 1 >= args.length) {
          _usageError('missing the date after --as-of');
        }
        asOf = _asOfOrUsage(args[++i]);
      default:
        if (arg.startsWith('--as-of=')) {
          asOf = _asOfOrUsage(arg.substring('--as-of='.length));
        } else {
          _usageError('unknown argument "$arg"');
        }
    }
  }

  final items = [
    ...countryRecheckItems(Countries.all),
    // Rule-set caveats join the countries (task C2): each caveat's
    // recheckBy is a work-queue item in the same weekly report.
    ...ruleSetCaveatRecheckItems(
      TaxJurisdiction.values.map(TaxRules.forJurisdiction),
    ),
  ];
  final report = freshnessReport(items: items, asOf: asOf);
  stdout.writeln(
    json ? formatFreshnessJson(report) : formatFreshnessText(report),
  );
}

/// The as-of day for [value], or a usage error when it is not a date.
DateTime _asOfOrUsage(String value) {
  final parsed = tryParseAsOfDate(value);
  if (parsed == null) {
    _usageError('--as-of expects YYYY-MM-DD, got "$value"');
  }
  return parsed;
}

Never _usageError(String message) {
  stderr
    ..writeln(message)
    ..writeln()
    ..writeln(_usage);
  exit(64);
}

// Generates lib/src/icons/openbudget_icons.g.dart, OpenBudget's hand-drawn
// icon vocabulary.
//
// Skribble's own glyphs are referenced directly. Concepts the glyph set does
// not draw come from the Skribble-roughened Lucide and Simple Icons catalogs,
// and only the drawings listed here are copied into the package as
// constants, so the app never ships the thousands of other icons and every
// icon stays `const`.
//
//   dart run tool/generate_openbudget_icons.dart          # write the catalog
//   dart run tool/generate_openbudget_icons.dart --check  # fail if stale
import 'dart:io';
import 'dart:isolate';

/// Where an icon's drawing comes from.
sealed class IconSource {
  const IconSource();
}

/// One of Skribble's own interface glyphs, by `SkribbleGlyphs` member name.
final class Glyph extends IconSource {
  const Glyph(this.name);
  final String name;
}

/// A Skribble-roughened Lucide drawing, by Lucide identifier.
final class Lucide extends IconSource {
  const Lucide(this.identifier);
  final String identifier;
}

/// A Skribble-roughened Simple Icons brand mark, by identifier.
final class Brand extends IconSource {
  const Brand(this.identifier);
  final String identifier;
}

typedef IconEntry = ({String name, IconSource source, String doc});

/// The catalog, in the order it is written. Name icons by what they mean in
/// OpenBudget, not by what they depict, so a drawing can change without
/// renaming call sites. Keep it to what the app draws: every entry ships.
const List<IconEntry> catalog = [
  // Moving through the app.
  (
    name: 'back',
    source: Glyph('arrowLeft'),
    doc: 'Return to the previous page.',
  ),
  (
    name: 'forward',
    source: Glyph('arrowRight'),
    doc: 'Continue to the next step.',
  ),
  (name: 'chevronRight', source: Glyph('chevronRight'), doc: 'Open the item.'),
  (
    name: 'chevronLeft',
    source: Glyph('chevronLeft'),
    doc: 'The previous item.',
  ),
  (name: 'chevronDown', source: Glyph('chevronDown'), doc: 'Show more.'),
  (name: 'chevronUp', source: Glyph('chevronUp'), doc: 'Show less.'),
  (
    name: 'expand',
    source: Lucide('chevrons-up-down'),
    doc: 'Choose from a list.',
  ),
  (name: 'close', source: Glyph('close'), doc: 'Dismiss or clear.'),
  (name: 'menu', source: Glyph('menu'), doc: 'Open the menu.'),
  (name: 'more', source: Glyph('moreHorizontal'), doc: 'More actions.'),
  (
    name: 'moreVertical',
    source: Glyph('moreVertical'),
    doc: 'More actions, stacked.',
  ),
  (
    name: 'apps',
    source: Lucide('layout-grid'),
    doc: 'Everything else in the app.',
  ),
  (name: 'home', source: Glyph('home'), doc: 'The home page.'),
  (
    name: 'externalLink',
    source: Lucide('external-link'),
    doc: 'Opens outside the app.',
  ),
  (name: 'link', source: Glyph('link'), doc: 'A link or a linked account.'),
  (name: 'addLink', source: Lucide('link-2'), doc: 'Link an account.'),
  (name: 'share', source: Glyph('share'), doc: 'Share outside the app.'),

  // Finding things.
  (name: 'search', source: Glyph('search'), doc: 'Search.'),
  (
    name: 'searchOff',
    source: Lucide('search-x'),
    doc: 'Nothing matched the search.',
  ),
  (name: 'filter', source: Lucide('funnel'), doc: 'Filter a list.'),
  (name: 'filterOff', source: Lucide('funnel-x'), doc: 'Clear the filters.'),
  (name: 'sort', source: Lucide('arrow-down-up'), doc: 'Change the order.'),
  (
    name: 'sortAlphabetical',
    source: Lucide('arrow-down-a-z'),
    doc: 'Sort by name.',
  ),
  (name: 'tune', source: Lucide('sliders-horizontal'), doc: 'Adjust options.'),
  (
    name: 'preview',
    source: Lucide('scan-search'),
    doc: 'Look before committing.',
  ),

  // Everyday actions.
  (name: 'add', source: Glyph('plus'), doc: 'Add something new.'),
  (
    name: 'addCircle',
    source: Lucide('circle-plus'),
    doc: 'Add an item to a list.',
  ),
  (name: 'remove', source: Glyph('minus'), doc: 'Take away.'),
  (
    name: 'removeCircle',
    source: Lucide('circle-minus'),
    doc: 'Remove an item from a list.',
  ),
  (name: 'edit', source: Glyph('edit'), doc: 'Edit.'),
  (name: 'editNote', source: Lucide('notebook-pen'), doc: 'Write a note.'),
  (name: 'delete', source: Glyph('delete'), doc: 'Delete.'),
  (name: 'copy', source: Glyph('copy'), doc: 'Copy to the clipboard.'),
  (name: 'undo', source: Lucide('undo-2'), doc: 'Undo the last change.'),
  (name: 'refresh', source: Glyph('refresh'), doc: 'Load again.'),
  (name: 'sync', source: Lucide('refresh-cw'), doc: 'Sync with the bank.'),
  (name: 'check', source: Glyph('check'), doc: 'Done, selected, or confirmed.'),
  (name: 'checkCircle', source: Lucide('circle-check'), doc: 'Complete.'),
  (
    name: 'taskDone',
    source: Lucide('circle-check-big'),
    doc: 'A finished task.',
  ),
  (name: 'checkAll', source: Lucide('check-check'), doc: 'Approve everything.'),
  (
    name: 'selectAll',
    source: Lucide('square-check-big'),
    doc: 'Select everything.',
  ),
  (name: 'deselect', source: Lucide('list-x'), doc: 'Clear the selection.'),
  (name: 'drag', source: Glyph('grip'), doc: 'Drag to reorder.'),
  (name: 'backspace', source: Lucide('delete'), doc: 'Delete the last digit.'),
  (
    name: 'enter',
    source: Lucide('corner-down-left'),
    doc: 'Confirm the entry.',
  ),
  (name: 'keypad', source: Lucide('calculator'), doc: 'Enter an amount.'),
  (name: 'upload', source: Glyph('upload'), doc: 'Upload.'),
  (name: 'download', source: Glyph('download'), doc: 'Download or export.'),
  (name: 'importFile', source: Lucide('file-up'), doc: 'Import from a file.'),
  (
    name: 'fileDone',
    source: Lucide('file-check'),
    doc: 'A file that was saved.',
  ),
  (name: 'play', source: Lucide('play'), doc: 'Start.'),
  (name: 'skip', source: Lucide('skip-forward'), doc: 'Skip this one.'),
  (name: 'snooze', source: Lucide('alarm-clock'), doc: 'Remind me later.'),
  (name: 'logout', source: Lucide('log-out'), doc: 'Sign out.'),
  (name: 'send', source: Glyph('send'), doc: 'Send.'),

  // Money and accounts.
  (name: 'bank', source: Lucide('landmark'), doc: 'A bank or an account.'),
  (name: 'wallet', source: Lucide('wallet'), doc: 'A wallet or cash account.'),
  (name: 'savings', source: Lucide('piggy-bank'), doc: 'Savings.'),
  (name: 'cash', source: Lucide('banknote'), doc: 'Cash and payments.'),
  (
    name: 'money',
    source: Lucide('circle-dollar-sign'),
    doc: 'An amount of money.',
  ),
  (name: 'coins', source: Lucide('coins'), doc: 'Tokens and change.'),
  (name: 'creditCard', source: Lucide('credit-card'), doc: 'A credit card.'),
  (name: 'receipt', source: Lucide('receipt-text'), doc: 'A transaction.'),
  (name: 'payment', source: Lucide('hand-coins'), doc: 'Paying a bill.'),
  (
    name: 'transfer',
    source: Lucide('arrow-left-right'),
    doc: 'Transfer between accounts.',
  ),
  (
    name: 'moveMoney',
    source: Lucide('arrow-up-down'),
    doc: 'Move money between envelopes.',
  ),
  (name: 'inflow', source: Glyph('arrowDown'), doc: 'Money coming in.'),
  (name: 'outflow', source: Glyph('arrowUp'), doc: 'Money going out.'),
  (
    name: 'trendingUp',
    source: Lucide('trending-up'),
    doc: 'Going up over time.',
  ),
  (
    name: 'trendingDown',
    source: Lucide('trending-down'),
    doc: 'Going down over time.',
  ),
  (
    name: 'priceChange',
    source: Lucide('tags'),
    doc: 'A changed price or rate.',
  ),
  (name: 'solana', source: Brand('solana'), doc: 'A Solana wallet.'),

  // Budgeting.
  (name: 'envelope', source: Lucide('mail'), doc: 'An envelope in the plan.'),
  (
    name: 'envelopeOpen',
    source: Lucide('mail-open'),
    doc: 'An envelope being filled.',
  ),
  (name: 'flag', source: Glyph('flag'), doc: 'A flagged transaction.'),
  (name: 'goal', source: Lucide('target'), doc: 'A goal for an envelope.'),
  (name: 'category', source: Lucide('tags'), doc: 'A category group.'),
  (name: 'label', source: Lucide('tag'), doc: 'A label or payee tag.'),
  (name: 'folder', source: Lucide('folder-open'), doc: 'A group of envelopes.'),
  (name: 'newFolder', source: Lucide('folder-plus'), doc: 'Add a group.'),
  (
    name: 'note',
    source: Lucide('sticky-note'),
    doc: 'A note on an envelope or transaction.',
  ),
  (name: 'document', source: Lucide('file-text'), doc: 'A document or memo.'),
  (name: 'recurring', source: Lucide('repeat'), doc: 'Repeats on a schedule.'),
  (name: 'schedule', source: Glyph('clock'), doc: 'Scheduled for later.'),
  (name: 'calendar', source: Glyph('calendar'), doc: 'A date.'),
  (name: 'calendarMonth', source: Lucide('calendar-days'), doc: 'A month.'),
  (name: 'event', source: Lucide('calendar-clock'), doc: 'An upcoming date.'),
  (name: 'history', source: Lucide('history'), doc: 'What happened before.'),
  (
    name: 'ageOfMoney',
    source: Lucide('hourglass'),
    doc: 'How long money waits before it is spent.',
  ),
  (name: 'speed', source: Lucide('gauge'), doc: 'A rate or pace.'),
  (name: 'split', source: Lucide('split'), doc: 'Split across envelopes.'),
  (name: 'merge', source: Lucide('git-merge'), doc: 'Combine two things.'),
  (name: 'rule', source: Lucide('list-checks'), doc: 'A transaction rule.'),
  (name: 'list', source: Lucide('list'), doc: 'A list.'),
  (
    name: 'autoAssign',
    source: Lucide('wand-sparkles'),
    doc: 'Fill envelopes automatically.',
  ),
  (
    name: 'insight',
    source: Lucide('sparkles'),
    doc: 'A suggestion or insight.',
  ),
  (name: 'sparkle', source: Glyph('sparkle'), doc: 'Something new.'),
  (name: 'quick', source: Lucide('zap'), doc: 'A quick action.'),
  (name: 'store', source: Lucide('store'), doc: 'A payee or shop.'),
  (name: 'groceries', source: Lucide('shopping-basket'), doc: 'Groceries.'),
  (name: 'transport', source: Lucide('bus'), doc: 'Transport.'),
  (name: 'nature', source: Lucide('leaf'), doc: 'Sustainability.'),
  (name: 'flower', source: Lucide('flower-2'), doc: 'A treat.'),
  (name: 'brain', source: Lucide('brain'), doc: 'Smart suggestions.'),
  (name: 'pin', source: Glyph('pin'), doc: 'Pinned.'),
  (name: 'bookmark', source: Glyph('bookmark'), doc: 'Saved.'),
  (name: 'favorite', source: Glyph('heart'), doc: 'A favourite.'),
  (name: 'star', source: Glyph('star'), doc: 'Important.'),
  (name: 'focus', source: Lucide('crosshair'), doc: 'Track a target.'),
  (name: 'adjust', source: Lucide('circle-dot'), doc: 'Fine-tune.'),

  // Reports.
  (name: 'pieChart', source: Lucide('chart-pie'), doc: 'Spending by share.'),
  (
    name: 'barChart',
    source: Lucide('chart-column'),
    doc: 'Spending over time.',
  ),
  (name: 'lineChart', source: Lucide('chart-line'), doc: 'A trend.'),
  (
    name: 'scatterChart',
    source: Lucide('chart-scatter'),
    doc: 'Spread of values.',
  ),
  (name: 'addChart', source: Lucide('chart-bar'), doc: 'Add a report.'),
  (name: 'scale', source: Lucide('ruler'), doc: 'A range or scale.'),
  (name: 'network', source: Lucide('network'), doc: 'Connected accounts.'),
  (name: 'tree', source: Lucide('workflow'), doc: 'A hierarchy.'),
  (name: 'extension', source: Lucide('puzzle'), doc: 'An integration.'),
  (name: 'package', source: Lucide('package'), doc: 'Holdings.'),
  (name: 'tool', source: Lucide('wrench'), doc: 'Tools and maintenance.'),

  // Status.
  (name: 'info', source: Glyph('info'), doc: 'More information.'),
  (name: 'warning', source: Glyph('warning'), doc: 'Needs attention.'),
  (name: 'error', source: Lucide('circle-alert'), doc: 'Something went wrong.'),
  (
    name: 'verified',
    source: Lucide('badge-check'),
    doc: 'Verified or reconciled.',
  ),
  (name: 'lock', source: Glyph('lock'), doc: 'Locked or private.'),
  (
    name: 'lockClock',
    source: Lucide('lock-keyhole'),
    doc: 'Locked until a date.',
  ),
  (name: 'visible', source: Glyph('eye'), doc: 'Shown.'),
  (name: 'hidden', source: Glyph('eyeOff'), doc: 'Hidden.'),
  (name: 'circle', source: Lucide('circle'), doc: 'Not yet done.'),
  (name: 'notification', source: Glyph('notification'), doc: 'A reminder.'),

  // People, settings, and appearance.
  (name: 'person', source: Glyph('user'), doc: 'You or a person.'),
  (name: 'personAdd', source: Lucide('user-plus'), doc: 'Add a person.'),
  (name: 'people', source: Lucide('users'), doc: 'Payees or people.'),
  (name: 'email', source: Glyph('mail'), doc: 'Email.'),
  (name: 'settings', source: Glyph('settings'), doc: 'Settings.'),
  (name: 'palette', source: Lucide('palette'), doc: 'Appearance.'),
  (name: 'lightMode', source: Glyph('sun'), doc: 'Paper (light) theme.'),
  (name: 'darkMode', source: Glyph('moon'), doc: 'Night (dark) theme.'),
  (name: 'image', source: Glyph('image'), doc: 'An image or icon.'),
];

const _lucideSource =
    'package:skribble_icons_lucide/src/generated/lucide_icons.g.dart';
const _simpleSource =
    'package:skribble_icons_simple/src/generated/simple_icons.g.dart';
const _outputPath = 'lib/src/icons/openbudget_icons.g.dart';

Future<void> main(List<String> arguments) async {
  final check = arguments.contains('--check');
  final rendered = await renderCatalog();
  final output = File(_outputPath);

  if (check) {
    if (!output.existsSync() || output.readAsStringSync() != rendered) {
      stderr.writeln(
        '$_outputPath is stale. Run: dart run tool/generate_openbudget_icons.dart',
      );
      exitCode = 1;
    }
    return;
  }

  output
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(rendered);
  stdout.writeln('Wrote ${catalog.length} icons to $_outputPath');
}

/// Renders the catalog from the drawings the resolved packages ship.
Future<String> renderCatalog() async {
  final lucide = await _read(_lucideSource);
  final simple = await _read(_simpleSource);
  return _format(render(lucide: lucide, simple: simple));
}

Future<String> _read(String packageUri) async {
  final uri = await Isolate.resolvePackageUri(Uri.parse(packageUri));
  if (uri == null) {
    throw StateError('Cannot resolve $packageUri. Run `flutter pub get`.');
  }
  return File.fromUri(uri).readAsStringSync();
}

/// Formats [source] as the repository's format gate would format the file.
Future<String> _format(String source) async {
  final process = await Process.start(Platform.resolvedExecutable, [
    'format',
    '--stdin-name',
    _outputPath,
  ]);
  process.stdin.write(source);
  await process.stdin.close();
  final (formatted, errors, code) = await (
    process.stdout.transform(systemEncoding.decoder).join(),
    process.stderr.transform(systemEncoding.decoder).join(),
    process.exitCode,
  ).wait;
  if (code != 0) {
    throw StateError('dart format failed: $errors');
  }
  return formatted;
}

/// Renders the catalog from the text of the generated source catalogs.
String render({required String lucide, required String simple}) {
  final names = <String>{};
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln(
      '// Regenerate with: dart run tool/generate_openbudget_icons.dart',
    )
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln('//')
    ..writeln('// Lucide drawings are ISC licensed, copyright Lucide')
    ..writeln(
      '// contributors (https://lucide.dev). Brand marks come from Simple',
    )
    ..writeln(
      '// Icons (CC0). Both are roughened by the skribble icon packages.',
    )
    ..writeln()
    ..writeln("import 'package:skribble/skribble.dart';")
    ..writeln()
    ..writeln("/// OpenBudget's hand-drawn icon vocabulary.")
    ..writeln('///')
    ..writeln(
      '/// Every icon is a stroke drawing inked by the active Skribble pen,',
    )
    ..writeln(
      '/// so it follows the theme and never renders a vector font glyph.',
    )
    ..writeln(
      '/// Draw one with `SkribbleIcon(data: OpenBudgetIcons.envelope)`.',
    )
    ..writeln('abstract final class OpenBudgetIcons {');

  for (final entry in catalog) {
    if (!names.add(entry.name)) {
      throw StateError('Duplicate icon name: ${entry.name}');
    }
    buffer
      ..writeln('  /// ${entry.doc}')
      ..writeln(switch (entry.source) {
        Glyph(:final name) =>
          '  static const ${entry.name} = SkribbleGlyphs.$name;',
        Lucide(:final identifier) =>
          '  static const ${entry.name} = ${_drawing(lucide, 'Lucide', identifier)};',
        Brand(:final identifier) =>
          '  static const ${entry.name} = ${_drawing(simple, 'Simple Icons', identifier)};',
      })
      ..writeln();
  }

  return '${buffer.toString().trimRight()}\n}\n';
}

/// Copies one `WiredSvgIconData(...)` literal out of a generated catalog.
String _drawing(String source, String catalogName, String identifier) {
  final codePoint = RegExp(
    "^  '${RegExp.escape(identifier)}': (0x[0-9a-f]+),\$",
    multiLine: true,
  ).firstMatch(source)?.group(1);
  if (codePoint == null) {
    throw StateError('$catalogName has no icon named "$identifier".');
  }

  const opener = 'WiredSvgIconData(';
  final start = source.indexOf('  $codePoint: $opener');
  if (start < 0) {
    throw StateError(
      '$catalogName has no drawing for $identifier ($codePoint).',
    );
  }
  final literalStart = source.indexOf(opener, start);
  var depth = 0;
  for (var index = literalStart; index < source.length; index++) {
    final char = source[index];
    if (char == '(') depth++;
    if (char == ')' && --depth == 0) {
      // Re-indent the literal from its map-entry depth to a class member.
      return source.substring(literalStart, index + 1).replaceAll('\n  ', '\n');
    }
  }
  throw StateError('Unterminated drawing for $identifier.');
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/icons/openbudget_icons.g.dart';
import 'package:openbudget_ui/src/theme/color_tokens.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/widgets/ob_field_icon.dart';
import 'package:openbudget_ui/src/widgets/ob_section_header.dart';
import 'package:openbudget_ui/src/widgets/ob_text_field.dart';
import 'package:skribble/skribble.dart';

/// One choice in an [showObPickerSheet].
///
/// The picker never looks inside [value]; it hands back the option's value
/// when the person picks it.
@immutable
class ObPickerOption<T> {
  const ObPickerOption({
    required this.value,
    required this.label,
    this.code,
    this.keywords = const [],
    this.section,
  });

  /// What the sheet returns when this option is picked.
  final T value;

  /// The name shown on the row, such as "Kenya".
  final String label;

  /// A short code shown at the end of the row and matched exactly first, such
  /// as the ISO code "KE".
  final String? code;

  /// Further words a search finds this option by, such as a currency symbol.
  final List<String> keywords;

  /// The heading this option sits under while the search is empty.
  ///
  /// Options arrive in display order; a heading appears wherever the section
  /// changes. Once the person types, rows rank by match and headings go.
  final String? section;
}

/// How many options a sheet shows before it adds a search field.
const int obPickerSearchThreshold = 8;

/// Opens a bottom sheet to pick one of [options], with search by label, code
/// and keywords.
///
/// Searching ignores case, accents and apostrophes, and ranks an exact code
/// first, then names that start with the query, then names with a word that
/// starts with it, then the rest. Enter picks the top result; the down arrow
/// moves from the field into the list. Sheets of [searchThreshold] options or
/// fewer skip the search field. [selected] gets the highlighter, a check and
/// a screen-reader "selected" state, and the list opens scrolled to it.
///
/// The widget library carries no strings, so every phrase comes from the
/// caller: [searchHint] and [clearSearchLabel] label the field,
/// [resultCountLabel] is the live count under it, [noMatchLabel] explains an
/// empty result, and [selectedLabel] is what a screen reader adds to the
/// chosen row.
Future<T?> showObPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<ObPickerOption<T>> options,
  required String searchHint,
  required String clearSearchLabel,
  required String selectedLabel,
  required String Function(int count) resultCountLabel,
  required String Function(String query) noMatchLabel,
  T? selected,
  int searchThreshold = obPickerSearchThreshold,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => ObPickerSheet<T>(
    title: title,
    options: options,
    selected: selected,
    searchHint: searchHint,
    clearSearchLabel: clearSearchLabel,
    selectedLabel: selectedLabel,
    resultCountLabel: resultCountLabel,
    noMatchLabel: noMatchLabel,
    searchThreshold: searchThreshold,
  ),
);

/// The body of [showObPickerSheet], exposed so it can be tested in place.
class ObPickerSheet<T> extends HookWidget {
  const ObPickerSheet({
    required this.title,
    required this.options,
    required this.searchHint,
    required this.clearSearchLabel,
    required this.selectedLabel,
    required this.resultCountLabel,
    required this.noMatchLabel,
    this.selected,
    this.searchThreshold = obPickerSearchThreshold,
    super.key,
  });

  final String title;
  final List<ObPickerOption<T>> options;
  final T? selected;
  final String searchHint;
  final String clearSearchLabel;
  final String selectedLabel;
  final String Function(int count) resultCountLabel;
  final String Function(String query) noMatchLabel;
  final int searchThreshold;

  /// Row and heading heights, used to open the list near the selection.
  static const double _rowExtent = 56;
  static const double _headerExtent = 52;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final searchable = options.length > searchThreshold;
    final controller = useTextEditingController();
    final query = useValueListenable(controller).text;
    final folded = useMemoized(
      () => [
        for (final option in options) _Folded(option),
      ],
      [options],
    );
    final matches = useMemoized(
      () => _search(folded, query),
      [folded, query],
    );
    final isSearching = query.trim().isNotEmpty;
    final entries = useMemoized(
      () => _entries(matches, groupBySection: !isSearching),
      [matches, isSearching],
    );
    final scroll = useScrollController(
      initialScrollOffset: _offsetOfSelection(entries, selected),
    );

    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final sheetHeight = (MediaQuery.sizeOf(context).height * 0.86 - viewInsets)
        .clamp(0.0, double.infinity);
    final desktop = const {
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    }.contains(defaultTargetPlatform);

    final list = entries.isEmpty
        ? _NoMatch(label: noMatchLabel(query.trim()))
        : ListView.builder(
            controller: scroll,
            shrinkWrap: !searchable,
            padding: const EdgeInsets.only(bottom: SpacingTokens.md),
            itemCount: entries.length,
            itemBuilder: (context, index) => switch (entries[index]) {
              _Heading<T>(:final title) => ObSectionHeader(
                title: title,
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  SpacingTokens.md,
                  SpacingTokens.md,
                  SpacingTokens.xs,
                ),
              ),
              _Row<T>(:final option) => _PickerRow<T>(
                option: option,
                selected: option.value == selected,
                selectedLabel: selectedLabel,
                onTap: () => Navigator.of(context).pop(option.value),
              ),
            },
          );

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        0,
        SpacingTokens.md,
        SpacingTokens.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: palette.ink,
              ),
            ),
          ),
          if (searchable) ...[
            const SizedBox(height: SpacingTokens.sm),
            CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                    FocusScope.of(context).focusInDirection(
                      TraversalDirection.down,
                    ),
              },
              child: ObTextField(
                controller: controller,
                hintText: searchHint,
                autofocus: desktop,
                prefixIcon: const ObFieldIcon(data: OpenBudgetIcons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: clearSearchLabel,
                        icon: const SkribbleIcon(data: OpenBudgetIcons.close),
                        onPressed: controller.clear,
                      ),
                // Read the field, not the last build: a key press can land
                // before the frame that rebuilds the list.
                onSubmitted: (text) {
                  final top = _search(folded, text);
                  if (top.isNotEmpty) {
                    Navigator.of(context).pop(top.first.option.value);
                  }
                },
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Semantics(
              liveRegion: true,
              child: Text(
                resultCountLabel(matches.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SafeArea(
        child: searchable
            ? SizedBox(
                height: sheetHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const Divider(height: 1),
                    Expanded(child: list),
                  ],
                ),
              )
            : ConstrainedBox(
                constraints: BoxConstraints(maxHeight: sheetHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const Divider(height: 1),
                    Flexible(child: list),
                  ],
                ),
              ),
      ),
    );
  }

  /// Where to start the list so [selected] is in view, as an estimate: the
  /// rows are never shorter than [_rowExtent], so the offset errs high only
  /// when text is scaled up, and the selection still lands on screen.
  static double _offsetOfSelection<T>(
    List<_Entry<T>> entries,
    T? selected,
  ) {
    if (selected == null) {
      return 0;
    }
    var offset = 0.0;
    for (final entry in entries) {
      if (entry is _Row<T> && entry.option.value == selected) {
        // A selection near the top leaves the list at the top, so the first
        // heading shows; further down, keep one row of context above it.
        return offset <= _rowExtent * 4 ? 0 : offset - _rowExtent;
      }
      offset += entry is _Heading<T> ? _headerExtent : _rowExtent;
    }
    return 0;
  }
}

/// An option with its search text folded once.
class _Folded<T> {
  _Folded(this.option)
    : label = foldForSearch(option.label),
      code = foldForSearch(option.code ?? ''),
      keywords = [for (final word in option.keywords) foldForSearch(word)];

  final ObPickerOption<T> option;
  final String label;
  final String code;
  final List<String> keywords;
}

/// Lowercases [text] and strips accents and apostrophes, so "Cote d'Ivoire"
/// finds "Côte d’Ivoire" and "turkiye" finds "Türkiye".
@visibleForTesting
String foldForSearch(String text) {
  final out = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    out.write(_folds[char] ?? char);
  }
  return out.toString().trim();
}

const Map<String, String> _folds = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ā': 'a',
  'ç': 'c',
  'ć': 'c',
  'č': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ı': 'i',
  'ğ': 'g',
  'ł': 'l',
  'ñ': 'n',
  'ń': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ş': 's',
  'š': 's',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ž': 'z',
  "'": '',
  '’': '',
  '‘': '',
};

/// The options that match [query], best first; every option when it is empty.
List<_Folded<T>> _search<T>(List<_Folded<T>> all, String query) {
  final needle = foldForSearch(query);
  if (needle.isEmpty) {
    return all;
  }
  final ranked = <(int, _Folded<T>)>[];
  for (final item in all) {
    final rank = _rank(item, needle);
    if (rank != null) {
      ranked.add((rank, item));
    }
  }
  // `List.sort` is not stable, so break ties on the original position.
  final position = {for (final (i, item) in all.indexed) item: i};
  ranked.sort((a, b) {
    final byRank = a.$1.compareTo(b.$1);
    return byRank != 0 ? byRank : position[a.$2]!.compareTo(position[b.$2]!);
  });
  return [for (final (_, item) in ranked) item];
}

int? _rank<T>(_Folded<T> item, String needle) {
  if (item.code == needle) {
    return 0;
  }
  if (item.label.startsWith(needle)) {
    return 1;
  }
  if (item.label.contains(' $needle')) {
    return 2;
  }
  if (item.label.contains(needle) ||
      (item.code.isNotEmpty && item.code.startsWith(needle)) ||
      item.keywords.any((word) => word.contains(needle))) {
    return 3;
  }
  return null;
}

sealed class _Entry<T> {
  const _Entry();
}

final class _Heading<T> extends _Entry<T> {
  const _Heading(this.title);

  final String title;
}

final class _Row<T> extends _Entry<T> {
  const _Row(this.option);

  final ObPickerOption<T> option;
}

List<_Entry<T>> _entries<T>(
  List<_Folded<T>> matches, {
  required bool groupBySection,
}) {
  final entries = <_Entry<T>>[];
  String? current;
  for (final match in matches) {
    final section = match.option.section;
    if (groupBySection && section != null && section != current) {
      entries.add(_Heading<T>(section));
      current = section;
    }
    entries.add(_Row<T>(match.option));
  }
  return entries;
}

class _PickerRow<T> extends HookWidget {
  const _PickerRow({
    required this.option,
    required this.selected,
    required this.selectedLabel,
    required this.onTap,
  });

  final ObPickerOption<T> option;
  final bool selected;
  final String selectedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    // The highlighter marks the choice, as it does on the kind selector;
    // the check and the spoken state say it without colour.
    final ink = selected ? palette.onHighlighter : palette.ink;
    final quiet = selected ? palette.onHighlighter : palette.mutedInk;
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        value: selected ? selectedLabel : null,
        child: Material(
          color: selected ? palette.highlighter : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            focusColor: palette.wash(ObTone.neutral),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: ObPickerSheet._rowExtent,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: ink,
                        ),
                      ),
                    ),
                    if (option.code case final code?) ...[
                      const SizedBox(width: SpacingTokens.sm),
                      Text(
                        code,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: quiet,
                        ),
                      ),
                    ],
                    if (selected) ...[
                      const SizedBox(width: SpacingTokens.sm),
                      ExcludeSemantics(
                        child: SkribbleIcon(
                          data: OpenBudgetIcons.check,
                          color: ink,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoMatch extends HookWidget {
  const _NoMatch({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: SkribbleIcon(
                data: OpenBudgetIcons.searchOff,
                color: palette.mutedInk,
                size: 40,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

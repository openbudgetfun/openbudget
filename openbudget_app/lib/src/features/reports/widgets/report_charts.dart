import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// One series value a report chart draws.
///
/// [value] is the magnitude in the report's smallest unit (cents for money).
/// [amountLabel] is the same figure already formatted for people, so a chart
/// never has to know a currency. [color] comes from [reportSeriesColors] or
/// another role on `Theme.of(context).ob`.
@immutable
class ReportChartDatum {
  const ReportChartDatum({
    required this.label,
    required this.amountLabel,
    required this.value,
    required this.color,
  });

  final String label;
  final String amountLabel;
  final int value;
  final Color color;
}

/// One column of a [ReportColumnChart]: a month, or a balance.
@immutable
class ReportChartColumn {
  const ReportChartColumn({required this.label, required this.values});

  final String label;
  final List<ReportChartDatum> values;
}

/// The six chart series colours, in reading order.
///
/// They are palette roles rather than raw colours, so charts follow light and
/// dark mode. Every chart also names its series in words, so colour is never
/// the only signal.
List<Color> reportSeriesColors(ThemeData theme) {
  final palette = theme.ob;
  return [
    palette.brand,
    palette.funded,
    palette.underfunded,
    palette.overspent,
    palette.review,
    palette.mutedInk,
  ];
}

/// A spoken summary of a chart: its title, then every series in words.
String reportChartSummary(
  AppLocalizations l10n, {
  required String title,
  required Iterable<(String, String)> entries,
}) => l10n.reportsChartSummary(
  title,
  entries
      .map((entry) => l10n.reportsChartSeriesEntry(entry.$1, entry.$2))
      .join(', '),
);

/// A month or category's share of a total, inked as one rough bar.
///
/// The bar grows in once when the platform allows motion. Its segments are
/// hatched with the pen rather than filled flat, and a legend beside it names
/// every share, so the drawing is decoration over a complete sentence.
class ReportShareBar extends HookWidget {
  const ReportShareBar({
    required this.segments,
    required this.semanticsLabel,
    this.height = 20,
    this.gap = 3,
    this.seed = 40,
    super.key,
  });

  final List<ReportChartDatum> segments;
  final String semanticsLabel;
  final double height;
  final double gap;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 420),
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    useEffect(() {
      if (reduceMotion) {
        controller.value = 1;
      } else {
        controller.forward(from: 0);
      }
      return null;
    }, [reduceMotion, controller]);

    final drawn = segments
        .where((segment) => segment.value > 0)
        .toList(growable: false);
    if (drawn.isEmpty) {
      return ObStatePanel.empty(
        title: l10n.reportsChartEmptyTitle,
        message: l10n.reportsChartEmptyMessage,
        doodle: WiredDoodleKind.scribble,
        tone: ObTone.neutral,
      );
    }

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) => CustomPaint(
              painter: _ShareBarPainter(
                segments: drawn,
                progress: controller.value,
                ink: palette.ink,
                track: palette.line,
                gap: gap,
                seed: seed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareBarPainter extends CustomPainter {
  const _ShareBarPainter({
    required this.segments,
    required this.progress,
    required this.ink,
    required this.track,
    required this.gap,
    required this.seed,
  });

  final List<ReportChartDatum> segments;
  final double progress;
  final Color ink;
  final Color track;
  final double gap;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final trackRect = (Offset.zero & size).deflate(1);
    ObPen.hatchedRect(canvas, trackRect, color: track, gap: 7, seed: seed);

    final total = segments.fold<int>(0, (sum, segment) => sum + segment.value);
    if (total <= 0 || progress <= 0) {
      return;
    }
    final inner = (Offset.zero & size).deflate(2);
    final available = math
        .max(0, inner.width - gap * (segments.length - 1))
        .toDouble();

    canvas
      ..save()
      ..clipRect(
        Rect.fromLTWH(
          inner.left,
          inner.top,
          inner.width * progress.clamp(0.0, 1.0),
          inner.height,
        ),
      );
    var left = inner.left;
    for (final (index, segment) in segments.indexed) {
      final segmentWidth = available * segment.value / total;
      if (segmentWidth <= 0) {
        continue;
      }
      final rect = Rect.fromLTWH(
        left,
        inner.top,
        math.max(segmentWidth, 2),
        inner.height,
      );
      canvas.drawRect(
        rect,
        Paint()..color = segment.color.withValues(alpha: 0.16),
      );
      ObPen.hatchedRect(
        canvas,
        rect,
        color: segment.color,
        gap: 4,
        seed: seed + index,
      );
      _outlineRect(canvas, rect, ink: ink, seed: seed + index);
      left += segmentWidth + gap;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShareBarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.ink != ink ||
      oldDelegate.track != track ||
      oldDelegate.gap != gap ||
      oldDelegate.seed != seed ||
      !_sameSegments(oldDelegate.segments, segments);
}

/// Vertical bars side by side, one group per column.
///
/// Each column is labelled underneath in the same slot the bars occupy, and
/// the caller pairs the chart with a [ReportChartLegend]. Bars rise in once
/// unless the platform asks for less motion.
class ReportColumnChart extends HookWidget {
  const ReportColumnChart({
    required this.columns,
    required this.semanticsLabel,
    this.height = 140,
    this.seed = 70,
    super.key,
  });

  final List<ReportChartColumn> columns;
  final String semanticsLabel;
  final double height;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 480),
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    useEffect(() {
      if (reduceMotion) {
        controller.value = 1;
      } else {
        controller.forward(from: 0);
      }
      return null;
    }, [reduceMotion, controller]);

    final hasValue = columns.any(
      (column) => column.values.any((value) => value.value > 0),
    );
    if (columns.isEmpty || !hasValue) {
      return ObStatePanel.empty(
        title: l10n.reportsChartEmptyTitle,
        message: l10n.reportsChartEmptyMessage,
        doodle: WiredDoodleKind.scribble,
        tone: ObTone.neutral,
      );
    }

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: height,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) => CustomPaint(
                  painter: _ColumnChartPainter(
                    columns: columns,
                    progress: controller.value,
                    ink: palette.ink,
                    line: palette.quietPen,
                    seed: seed,
                  ),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Row(
              children: [
                for (final column in columns)
                  Expanded(
                    child: Text(
                      column.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnChartPainter extends CustomPainter {
  const _ColumnChartPainter({
    required this.columns,
    required this.progress,
    required this.ink,
    required this.line,
    required this.seed,
  });

  final List<ReportChartColumn> columns;
  final double progress;
  final Color ink;
  final Color line;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || columns.isEmpty) {
      return;
    }
    final baselineY = size.height - 2;
    ObPen.stroke(
      canvas,
      [Offset(1, baselineY), Offset(size.width - 1, baselineY)],
      color: line,
      strokeWidth: 1.6,
      seed: seed,
    );
    if (progress <= 0) {
      return;
    }

    final maxValue = columns.fold<int>(
      0,
      (max, column) =>
          math.max(max, column.values.fold(0, (m, v) => math.max(m, v.value))),
    );
    if (maxValue <= 0) {
      return;
    }

    // Clip rather than resize: the pen drawings keep one stable geometry, so
    // their rough shared outlines stay cached for the whole animation.
    canvas
      ..save()
      ..clipRect(
        Rect.fromLTRB(
          0,
          size.height * (1 - progress.clamp(0.0, 1.0)),
          size.width,
          size.height,
        ),
      );
    final slot = size.width / columns.length;
    var index = 0;
    for (final column in columns) {
      final values = column.values.where((value) => value.value > 0).toList();
      if (values.isEmpty) {
        index += 1;
        continue;
      }
      final horizontalPad = math.min(8, slot * 0.14).toDouble();
      const barGap = 3;
      final usable = math.max(0, slot - horizontalPad * 2).toDouble();
      final barWidth = math
          .max(2, (usable - barGap * (values.length - 1)) / values.length)
          .toDouble();
      var x = index * slot + horizontalPad;
      for (final (valueIndex, value) in values.indexed) {
        final barHeight = (size.height - 10) * value.value / maxValue;
        final rect = Rect.fromLTWH(
          x,
          baselineY - barHeight,
          barWidth,
          math.max(barHeight, 1),
        );
        canvas.drawRect(
          rect,
          Paint()..color = value.color.withValues(alpha: 0.16),
        );
        ObPen.hatchedRect(
          canvas,
          rect,
          color: value.color,
          gap: 4,
          seed: seed + index * 7 + valueIndex,
        );
        _outlineRect(
          canvas,
          rect,
          ink: ink,
          seed: seed + index * 7 + valueIndex,
        );
        x += barWidth + barGap;
      }
      index += 1;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ColumnChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.ink != ink ||
      oldDelegate.line != line ||
      oldDelegate.seed != seed ||
      !_sameColumns(oldDelegate.columns, columns);
}

/// A single horizontal share bar on its quiet track.
///
/// Used where a chart is a list of rows rather than one drawing; the label
/// and figure beside it say the same thing in words.
class ReportTrackBar extends HookWidget {
  const ReportTrackBar({
    required this.fraction,
    required this.tone,
    this.height = 10,
    this.seed = 70,
    super.key,
  });

  final double fraction;
  final ObTone tone;
  final double height;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _TrackBarPainter(
            fraction: fraction.isFinite ? fraction.clamp(0.0, 1.0) : 0,
            fill: palette.wash(tone),
            hue: palette.hue(tone),
            ink: palette.ink,
            track: palette.highlight,
            seed: seed,
          ),
        ),
      ),
    );
  }
}

class _TrackBarPainter extends CustomPainter {
  const _TrackBarPainter({
    required this.fraction,
    required this.fill,
    required this.hue,
    required this.ink,
    required this.track,
    required this.seed,
  });

  final double fraction;
  final Color fill;
  final Color hue;
  final Color ink;
  final Color track;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final rect = (Offset.zero & size).deflate(1);
    canvas.drawRect(rect, Paint()..color = track);
    if (fraction > 0) {
      final barRect = Rect.fromLTWH(
        rect.left,
        rect.top,
        math.max(rect.width * fraction, 2),
        rect.height,
      );
      canvas.drawRect(barRect, Paint()..color = fill);
      ObPen.hatchedRect(canvas, barRect, color: hue, gap: 3.5, seed: seed + 7);
    }
    ObPen.outline(
      canvas,
      size,
      color: ink,
      radius: 3,
      strokeWidth: 1.2,
      seed: seed,
    );
  }

  @override
  bool shouldRepaint(_TrackBarPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.fill != fill ||
      oldDelegate.hue != hue ||
      oldDelegate.ink != ink ||
      oldDelegate.track != track ||
      oldDelegate.seed != seed;
}

/// A chart's legend: one rough swatch, one label, one figure per series.
class ReportChartLegend extends HookWidget {
  const ReportChartLegend({required this.entries, this.seed = 80, super.key});

  final List<ReportChartDatum> entries;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        for (final (index, entry) in entries.indexed)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == entries.length - 1 ? 0 : SpacingTokens.xs,
            ),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 20,
                  child: DecoratedBox(
                    decoration: ObRoughDecoration(
                      color: entry.color,
                      outline: palette.ink,
                      radius: 4,
                      strokeWidth: 1.4,
                      seed: seed + index,
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    entry.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.ink,
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                if (entry.amountLabel.isNotEmpty)
                  ObAmount(
                    entry.amountLabel,
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

void _outlineRect(
  Canvas canvas,
  Rect rect, {
  required Color ink,
  required int seed,
}) {
  if (rect.isEmpty) {
    return;
  }
  canvas
    ..save()
    ..translate(rect.left, rect.top);
  ObPen.outline(
    canvas,
    rect.size,
    color: ink,
    radius: 3,
    strokeWidth: 1.4,
    seed: seed,
  );
  canvas.restore();
}

bool _sameSegments(List<ReportChartDatum> a, List<ReportChartDatum> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var index = 0; index < a.length; index++) {
    final left = a[index];
    final right = b[index];
    if (left.label != right.label ||
        left.amountLabel != right.amountLabel ||
        left.value != right.value ||
        left.color != right.color) {
      return false;
    }
  }
  return true;
}

bool _sameColumns(List<ReportChartColumn> a, List<ReportChartColumn> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var index = 0; index < a.length; index++) {
    final left = a[index];
    final right = b[index];
    if (left.label != right.label ||
        !_sameSegments(left.values, right.values)) {
      return false;
    }
  }
  return true;
}

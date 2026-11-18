import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/theme/ob_rough_decoration.dart';

/// An icon on a small tile of spot ink, leading a row.
///
/// Rows of accounts, payees and categories get their own spot so a list
/// scans by colour as well as by name. [spot] picks the ink from
/// [ObPalette.spots]; the same index always gets the same ink. The icon is
/// drawn in [ObPalette.onAction], which every spot carries at AA.
class ObIconBadge extends HookWidget {
  const ObIconBadge({
    required this.icon,
    this.spot = 0,
    this.size = 40,
    this.seed = 13,
    super.key,
  });

  final Widget icon;
  final int spot;
  final double size;
  final int seed;

  /// A stable spot index for [key], such as a payee's name.
  static int spotFor(String key) =>
      key.codeUnits.fold(0, (sum, unit) => (sum * 31 + unit) & 0xFFFFF);

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ObRoughDecoration(
        color: palette.spot(spot),
        outline: palette.ink,
        strokeWidth: 1.8,
        seed: seed + spot,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: palette.onAction, size: size * 0.5),
        child: icon,
      ),
    );
  }
}

/// One row of a list: a leading badge, a title over a quiet subtitle, and
/// a trailing figure or control.
///
/// The row is at least 56 points tall, so a tap target never shrinks below
/// 48. With [onTap] the whole row is one target.
class ObListRow extends HookWidget {
  const ObListRow({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (leading case final badge?) ...[
              badge,
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: palette.ink,
                    ),
                  ),
                  if (subtitle case final text?)
                    Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing case final end?) ...[
              const SizedBox(width: 12),
              end,
            ],
          ],
        ),
      ),
    );
    if (onTap == null) {
      return row;
    }
    return InkWell(onTap: onTap, child: row);
  }
}

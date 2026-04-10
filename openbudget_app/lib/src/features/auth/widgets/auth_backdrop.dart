import 'package:flutter/material.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';

/// Decorative gradient backdrop used on auth screens.
class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topGlow = OpenBudgetPalette.bgHeroBlobPrimaryFor(theme);
    final sideGlow = OpenBudgetPalette.bgHeroBlobSecondaryFor(theme);
    final accentGlow = OpenBudgetPalette.bgHeroBlobAccentFor(theme);

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                OpenBudgetPalette.bgHeroGradientStartFor(
                  theme,
                ).withAlpha(theme.brightness == Brightness.dark ? 92 : 76),
                OpenBudgetPalette.bgHeroGradientEndFor(
                  theme,
                ).withAlpha(theme.brightness == Brightness.dark ? 56 : 44),
                OpenBudgetPalette.bgAuthFor(theme),
              ],
              stops: const [0, 0.42, 1],
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: _GlowOrb(color: topGlow, size: 280),
        ),
        Positioned(
          top: 140,
          left: -110,
          child: _GlowOrb(color: sideGlow, size: 250),
        ),
        Positioned(
          bottom: -120,
          right: -40,
          child: _GlowOrb(color: accentGlow, size: 230),
        ),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withAlpha(150), color.withAlpha(0)],
            stops: const [0, 1],
          ),
        ),
      ),
    );
}

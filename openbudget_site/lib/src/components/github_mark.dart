import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The GitHub mark, drawn by hand, set before a link's words.
///
/// The path is Simple Icons' GitHub glyph (CC0) as `skribble_icons_simple`
/// redraws it with a pen, so it sits with the page's doodles. It is
/// decoration: the link's text still names GitHub for screen readers.
final class GithubMark extends StatelessComponent {
  const GithubMark({super.key});

  @override
  Component build(BuildContext context) => const RawText(githubMarkSvg);
}

/// The inline SVG [GithubMark] renders.
const githubMarkSvg =
    '<svg class="github-mark" viewBox="0 0 24 24" aria-hidden="true" '
    'focusable="false"><path fill="currentColor" '
    'd="M12.000 0.297C5.087 0.014 0.283 5.953 0.000 12.297C-0.325 '
    '17.834 3.763 21.863 8.205 23.682C8.853 23.863 8.977 23.356 '
    '9.025 23.105C9.195 22.819 8.845 22.066 9.010 21.065C5.806 '
    '21.452 4.834 19.792 4.968 19.455C4.568 17.959 3.487 17.811 '
    '3.633 17.700C2.607 16.963 3.656 16.964 3.717 16.971C4.819 '
    '17.208 5.658 18.054 5.555 18.207C6.542 20.333 8.447 19.221 '
    '9.050 19.205C9.292 18.492 9.333 17.837 9.810 17.600C7.439 '
    '17.029 4.050 16.539 4.344 11.670C4.612 10.463 4.541 9.187 '
    '5.579 8.450C5.709 8.156 4.774 6.918 5.684 5.274C5.582 5.549 '
    '6.792 4.677 8.984 6.504C9.978 6.487 10.930 5.855 11.984 '
    '6.099C12.970 6.355 14.058 5.987 14.984 6.504C17.366 5.226 '
    '18.166 5.000 18.269 5.274C18.649 6.937 18.774 8.137 18.389 '
    '8.450C18.886 9.393 19.887 10.258 19.619 11.670C19.325 16.008 '
    '17.108 17.567 14.144 17.590C14.379 18.017 15.139 18.619 14.954 '
    '19.810C14.680 21.415 15.213 22.707 14.939 23.096C14.892 23.480 '
    '15.197 23.717 15.764 23.666C20.889 22.327 23.676 17.357 24.000 '
    '12.297C24.283 5.387 18.344 0.580 12.000 0.297"/></svg>';

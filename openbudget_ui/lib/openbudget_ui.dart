/// Shared Flutter widgets and theme for OpenBudget.
///
/// The look is a two-colour print zine: a newsprint page, one deep ink,
/// spot inks laid down slightly off-register, hand-drawn outlines from
/// Skribble, and a highlighter for the money that is ready to assign. Read colour roles with `Theme.of(context).ob`.
library;

// The Skribble pieces app code draws with directly, so features depend on
// one design package rather than reaching into the drawing engine.
export 'package:skribble/skribble.dart'
    show
        SkribbleIcon,
        WiredDoodle,
        WiredDoodleKind,
        WiredLoadingIndicator,
        WiredRoughness,
        WiredSvgIconData;

export 'src/flourish/ob_ink_burst.dart';
export 'src/flourish/ob_postmark.dart';
export 'src/flourish/ob_scribble_underline.dart';
export 'src/flourish/ob_spot_doodle.dart';
export 'src/icons/openbudget_icons.g.dart';
export 'src/motion/ob_ink_transition.dart';
export 'src/motion/ob_motion.dart';
export 'src/theme/color_tokens.dart';
export 'src/theme/ob_palette.dart';
export 'src/theme/ob_pen.dart';
export 'src/theme/ob_rough_border.dart';
export 'src/theme/ob_rough_decoration.dart';
export 'src/theme/ob_skribble_theme.dart';
export 'src/theme/openbudget_theme.dart';
export 'src/widgets/ob_amount.dart';
export 'src/widgets/ob_button.dart';
export 'src/widgets/ob_card.dart';
export 'src/widgets/ob_dropdown.dart';
export 'src/widgets/ob_envelope_gauge.dart';
export 'src/widgets/ob_field_icon.dart';
export 'src/widgets/ob_highlighter.dart';
export 'src/widgets/ob_list_row.dart';
export 'src/widgets/ob_mark.dart';
export 'src/widgets/ob_section_header.dart';
export 'src/widgets/ob_state_panel.dart';
export 'src/widgets/ob_text_field.dart';
export 'src/widgets/ob_tone_chip.dart';

/// Guardrail data the Money guide, the packs, the server and MCP clients
/// share: per-country regulatory perimeters, the never-suggest list,
/// signpost triggers and disclaimer keys (money-guide section 7.4).
///
/// All of it is ported from the `tax-planning-guardrails` skill's
/// references; the design rules are inference pending review by counsel in
/// each jurisdiction.
library;

export 'disclaimer.dart';
export 'guidance_perimeter.dart';
export 'never_suggest.dart';
export 'signpost.dart';
export 'wording.dart';

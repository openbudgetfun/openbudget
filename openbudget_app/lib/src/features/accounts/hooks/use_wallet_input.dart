import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/src/features/accounts/utils/add_wallet_labels.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// What the paste field's text means right now.
@immutable
class WalletInput {
  const WalletInput({
    required this.result,
    required this.clearedRefusal,
    required this.length,
  });

  /// The parser's answer for the current text, or null for an empty field.
  final WalletAddressParseResult? result;

  /// The refusal for a secret that was pasted and cleared from the field.
  /// It stays until the person types something else.
  final WalletAddressRefusal? clearedRefusal;

  /// How many characters the field holds, ignoring surrounding space.
  final int length;

  /// The accepted candidates, or none.
  List<WalletAddressCandidate> get candidates => switch (result) {
    WalletAddressMatch(:final candidates) => candidates,
    _ => const [],
  };

  /// The refusal to explain: a secret that was cleared, or a form the
  /// parser refused that is still in the field.
  WalletAddressRefusal? get refusal =>
      clearedRefusal ??
      switch (result) {
        WalletAddressRefused(:final refusal) => refusal,
        _ => null,
      };

  /// The parser's hint for input that is not an address, once enough has
  /// been typed for the hint to help rather than nag.
  String? get invalidHint => switch (result) {
    WalletAddressInvalid(:final hint) when length >= _minAddressLength => hint,
    _ => null,
  };
}

/// The shortest address any supported chain uses (an XRP Ledger account is
/// 25 characters), so nothing shorter is called invalid while it is typed.
const _minAddressLength = 25;

/// Three or more words in a row is a recovery phrase in the making, never an
/// address, so a partial one is treated as secret too.
const _partialPhraseWords = 3;

/// Parses the text of [controller] as it changes, and clears the field the
/// moment a secret lands in it.
///
/// A private key, a recovery phrase or a run of words is never kept: the
/// listener empties the controller before the next frame, so the text is
/// never drawn. Only the kind of refusal is remembered, never the text, so
/// the secret appears in no state, log or semantics.
WalletInput useWalletInput(TextEditingController controller) {
  final parsed = useState<WalletAddressParseResult?>(null);
  final cleared = useState<WalletAddressRefusal?>(null);
  final length = useState(0);

  useEffect(() {
    void parseText() {
      final text = controller.text;
      final trimmed = text.trim();
      if (trimmed.isEmpty) {
        parsed.value = null;
        length.value = 0;
        return;
      }
      final result = _parse(trimmed);
      if (result case WalletAddressRefused(:final refusal)
          when isSecretRefusal(refusal)) {
        // Clearing notifies this listener again, with an empty field.
        controller.clear();
        cleared.value = refusal;
        return;
      }
      parsed.value = result;
      length.value = trimmed.length;
      cleared.value = null;
    }

    controller.addListener(parseText);
    parseText();
    return () => controller.removeListener(parseText);
  }, [controller]);

  return WalletInput(
    result: parsed.value,
    clearedRefusal: cleared.value,
    length: length.value,
  );
}

WalletAddressParseResult _parse(String trimmed) {
  final result = WalletAddressParser.parse(trimmed);
  if (result is WalletAddressInvalid &&
      trimmed.split(RegExp(r'\s+')).length >= _partialPhraseWords) {
    return const WalletAddressRefused(WalletAddressRefusal.recoveryPhrase);
  }
  return result;
}

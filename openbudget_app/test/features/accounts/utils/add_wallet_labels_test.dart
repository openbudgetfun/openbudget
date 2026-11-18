import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/utils/add_wallet_labels.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../fixtures/add_wallet_fixtures.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  WalletAddressCandidate candidateFor(String input) =>
      (WalletAddressParser.parse(input) as WalletAddressMatch).candidates.first;

  group('secret refusals', () {
    test('clear the field for a private key or a recovery phrase only', () {
      final secret = {
        for (final refusal in WalletAddressRefusal.values)
          if (isSecretRefusal(refusal)) refusal,
      };
      expect(secret, {
        WalletAddressRefusal.privateKey,
        WalletAddressRefusal.recoveryPhrase,
        WalletAddressRefusal.evmPrivateKey,
      });
    });

    test('every refusal has a title and plain words', () {
      for (final refusal in WalletAddressRefusal.values) {
        final copy = walletRefusalCopy(l10n, refusal);
        expect(copy.title, isNotEmpty, reason: refusal.name);
        expect(copy.message, isNotEmpty, reason: refusal.name);
      }
    });

    test('the private key words say what to do and never echo the input', () {
      final copy = walletRefusalCopy(l10n, WalletAddressRefusal.recoveryPhrase);
      expect(copy.title, "That's a private key");
      expect(copy.message, contains('OpenBudget never needs it'));
      expect(copy.message, contains("Don't share it with anyone"));
    });
  });

  group('walletInvalidMessage', () {
    String hintFor(String input) =>
        (WalletAddressParser.parse(input) as WalletAddressInvalid).hint;

    test("maps the parser's hints to the localised words", () {
      // These inputs produce the parser's hints. If the core wording changes,
      // this fails instead of silently showing the wrong message.
      expect(
        walletInvalidMessage(
          l10n,
          hintFor(fixtureEvmAddress.replaceRange(40, 41, 'D')),
        ),
        l10n.walletAddInvalidChecksum,
      );
      expect(
        walletInvalidMessage(l10n, hintFor('hello-this-is-not-an-address')),
        l10n.walletAddInvalidInput,
      );
      // Building a key with an unassigned version needs a Base58Check
      // encoder the core keeps private, so this hint is pinned by its text.
      expect(
        walletInvalidMessage(
          l10n,
          "That extended key isn't one OpenBudget recognises.",
        ),
        l10n.walletAddInvalidKey,
      );
    });
  });

  group('shortWalletAddress', () {
    test('keeps the first and last four characters', () {
      expect(shortWalletAddress(fixtureEvmAddress), '0x5a…eAed');
    });

    test('leaves a short value whole', () {
      expect(shortWalletAddress('0x5aAeb'), '0x5aAeb');
    });
  });

  test("walletKeyType is the key's first four letters, lowercased", () {
    expect(walletKeyType(fixtureZpub), 'zpub');
    expect(walletKeyType('  $fixtureXpub '), 'xpub');
    expect(walletKeyType('yp'), 'yp');
  });

  group('walletNetworkListLabel', () {
    test('reads as a phrase', () {
      expect(walletNetworkListLabel(l10n, const []), '');
      expect(
        walletNetworkListLabel(l10n, const [WalletNetwork.ethereumMainnet]),
        'Ethereum',
      );
      expect(
        walletNetworkListLabel(l10n, const [
          WalletNetwork.ethereumMainnet,
          WalletNetwork.baseMainnet,
        ]),
        'Ethereum and Base',
      );
      expect(
        walletNetworkListLabel(l10n, const [
          WalletNetwork.ethereumMainnet,
          WalletNetwork.baseMainnet,
          WalletNetwork.arbitrumOne,
        ]),
        'Ethereum, Base and Arbitrum One',
      );
      expect(
        walletNetworkListLabel(l10n, evmNetworks),
        startsWith(
          'Ethereum, Base, Arbitrum One and 4 more',
        ),
      );
    });
  });

  group('walletAccountName', () {
    test('names an address by chain and its shortened form', () {
      expect(
        walletAccountName(
          l10n,
          candidate: candidateFor(fixtureEvmAddress),
          input: fixtureEvmAddress,
        ),
        'Ethereum wallet (0x5a…eAed)',
      );
    });

    test('names an HD key by chain and key type', () {
      expect(
        walletAccountName(
          l10n,
          candidate: candidateFor(fixtureZpub),
          input: fixtureZpub,
        ),
        'Bitcoin wallet, zpub',
      );
    });
  });
}

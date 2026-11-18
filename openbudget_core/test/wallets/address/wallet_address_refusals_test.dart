import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

import 'address_test_helpers.dart';

WalletAddressRefused _refused(String input) {
  final result = WalletAddressParser.parse(input);
  expect(result, isA<WalletAddressRefused>(), reason: 'expected a refusal');
  return result as WalletAddressRefused;
}

void _expectNoMatch(String input) {
  expect(
    WalletAddressParser.parse(input),
    isNot(isA<WalletAddressMatch>()),
    reason: 'expected no match',
  );
}

void main() {
  group('private keys and recovery phrases', () {
    // BIP 39's canonical test phrase and the same words at every other
    // allowed length.
    const twelveWords =
        'abandon abandon abandon abandon abandon abandon abandon abandon '
        'abandon abandon abandon about';

    test('refuses recovery phrases of 12, 15, 18, 21 and 24 words', () {
      expect(
        _refused(twelveWords).refusal,
        WalletAddressRefusal.recoveryPhrase,
      );
      for (final count in [15, 18, 21, 24]) {
        final phrase = List.filled(count, 'abandon').join(' ');
        expect(
          _refused(phrase).refusal,
          WalletAddressRefusal.recoveryPhrase,
        );
      }
    });

    test('does not refuse a word count outside the BIP 39 set', () {
      final phrase = List.filled(13, 'abandon').join(' ');
      expect(
        WalletAddressParser.parse(phrase),
        isA<WalletAddressInvalid>(),
      );
    });

    // WIF test vectors: the uncompressed key from the Bitcoin wiki and the
    // compressed keys from BIP 32 and the Bitcoin wiki.
    const wifKeys = [
      '5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ',
      'KwdMAjGmerYanjeui5SHS7JkmpZvVipYvB2LJGU1ZxJwYvP98617',
      'L1aW4aubDFB7yfras2S1mN3bqg9nwySY8nkoLmJebSLD5BWv3ENZ',
    ];

    test('refuses WIF private keys', () {
      for (final key in wifKeys) {
        expect(_refused(key).refusal, WalletAddressRefusal.privateKey);
      }
    });

    test('refuses a testnet WIF private key', () {
      final key = base58CheckEncode([
        0xef,
        ...List.filled(32, 7),
        0x01,
      ]);
      expect(_refused(key).refusal, WalletAddressRefusal.privateKey);
    });

    // BIP 32 test vector 1 master private key, re-versioned per SLIP-132.
    const xprv =
        'xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi';

    test('refuses xprv, yprv and zprv', () {
      expect(_refused(xprv).refusal, WalletAddressRefusal.privateKey);
      expect(
        _refused(reVersionExtendedKey(xprv, 0x049d7878)).refusal,
        WalletAddressRefusal.privateKey,
      );
      expect(
        _refused(reVersionExtendedKey(xprv, 0x04b2430c)).refusal,
        WalletAddressRefusal.privateKey,
      );
    });

    test('refuses 64 hex digits without 0x', () {
      const key =
          '0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d';
      expect(_refused(key).refusal, WalletAddressRefusal.privateKey);
    });

    test('refuses a Base58 string that decodes to 64 bytes', () {
      final secret = base58Encode(List.generate(64, (index) => index));
      expect(_refused(secret).refusal, WalletAddressRefusal.privateKey);
    });

    test('refuses a JSON array of 64 byte values', () {
      final secret = List.generate(64, (index) => index).toString();
      expect(_refused(secret).refusal, WalletAddressRefusal.privateKey);

      final tooLarge = List.generate(64, (index) => index).toList()..[63] = 256;
      expect(
        WalletAddressParser.parse(tooLarge.toString()),
        isA<WalletAddressInvalid>(),
      );
    });
  });

  group('EVM private-key shape', () {
    test('refuses 0x followed by 64 hex digits', () {
      final key = '0x${List.filled(64, 'a').join()}';
      expect(_refused(key).refusal, WalletAddressRefusal.evmPrivateKey);
    });
  });

  group('multisig keys', () {
    const xpub =
        'xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8';

    test('refuses Ypub and Zpub', () {
      expect(
        _refused(reVersionExtendedKey(xpub, 0x0295b43f)).refusal,
        WalletAddressRefusal.multisigKey,
      );
      expect(
        _refused(reVersionExtendedKey(xpub, 0x02aa7ed3)).refusal,
        WalletAddressRefusal.multisigKey,
      );
    });
  });

  group('testnet forms', () {
    const xpub =
        'xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8';

    test('refuses tpub, vpub and upub', () {
      for (final version in [0x043587cf, 0x045f1cf6, 0x044a5262]) {
        expect(
          _refused(reVersionExtendedKey(xpub, version)).refusal,
          WalletAddressRefusal.testnet,
        );
      }
    });

    test('refuses tb1, m/n and 2 addresses', () {
      expect(
        _refused(
          'tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7',
        ).refusal,
        WalletAddressRefusal.testnet,
      );
      final p2pkh = base58CheckEncode([0x6f, ...List.filled(20, 1)]);
      final p2sh = base58CheckEncode([0xc4, ...List.filled(20, 2)]);
      expect(p2pkh, startsWith('m'));
      expect(p2sh, startsWith('2'));
      expect(_refused(p2pkh).refusal, WalletAddressRefusal.testnet);
      expect(_refused(p2sh).refusal, WalletAddressRefusal.testnet);
    });

    test('refuses a testnet X-address', () {
      expect(
        _refused(
          'TVK3SYvMLZR6rEtLDZh3saYHaqFSeMpn3Dz7EsmQC63VUwh',
        ).refusal,
        WalletAddressRefusal.testnet,
      );
    });

    test('refuses a TON user-friendly address with the testnet flag', () {
      final address = tonFriendlyAddress(
        tag: 0x91,
        workchain: 0,
        accountHash: List.filled(32, 7),
      );
      expect(address, hasLength(48));
      expect(_refused(address).refusal, WalletAddressRefusal.testnet);
    });

    test('does not treat a mainnet TON address as a wallet', () {
      final address = tonFriendlyAddress(
        tag: 0x51,
        workchain: 0,
        accountHash: List.filled(32, 7),
      );
      _expectNoMatch(address);
    });
  });

  group('X-address tags', () {
    test('refuses a mainnet X-address carrying a tag', () {
      expect(
        _refused(
          'XVPcpSm47b1CZkf5AkKM9a84dQHe3mTAxgxfLw2qYoe7Boa',
        ).refusal,
        WalletAddressRefusal.xAddressWithTag,
      );
    });
  });
}

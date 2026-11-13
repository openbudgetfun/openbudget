import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

import 'address_test_helpers.dart';

WalletAddressMatch _match(String input) {
  final result = WalletAddressParser.parse(input);
  expect(result, isA<WalletAddressMatch>(), reason: 'expected a match');
  return result as WalletAddressMatch;
}

void _expectNoMatch(String input) {
  expect(
    WalletAddressParser.parse(input),
    isNot(isA<WalletAddressMatch>()),
    reason: 'expected no match',
  );
}

void main() {
  group('BIP 173 test vectors', () {
    // Source: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
    // section "Test vectors". Version 1 and higher samples were valid under
    // BIP 173 but are invalid under BIP 350's Bech32m rule; the parser follows
    // the current rule.
    const validSegwit = [
      'BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4',
      'tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7',
      'bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx',
      'BC1SW50QA3JX3S',
      'bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj',
      'tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy',
    ];

    test('accepts the version 0 addresses and refuses the testnet ones', () {
      final first = _match(validSegwit[0]);
      expect(first.candidate.family, WalletAddressFamily.bitcoin);
      expect(
        first.candidate.canonical,
        'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
      );
      expect(first.candidate.networks, ['bitcoinMainnet']);

      expect(
        WalletAddressParser.parse(validSegwit[1]),
        isA<WalletAddressRefused>(),
      );
      // Version 1 with a Bech32 checksum, and version 16 with Bech32, are
      // invalid since BIP 350.
      _expectNoMatch(validSegwit[2]);
      _expectNoMatch(validSegwit[3]);
      _expectNoMatch(validSegwit[4]);
      expect(
        WalletAddressParser.parse(validSegwit[5]),
        isA<WalletAddressRefused>(),
      );
    });

    const invalidSegwit = [
      'tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty',
      'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5',
      'BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2',
      'bc1rw5uspcuh',
      'bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90',
      'BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P',
      'tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7',
      'bc1zw508d6qejxtdg4y5r3zarvaryvqyzf3du',
      'tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3pjxtptv',
      'bc1gmk9yu',
    ];

    test('rejects every invalid segwit address', () {
      invalidSegwit.forEach(_expectNoMatch);
    });

    // The generic Bech32 lists contain valid strings on other human-readable
    // parts. They are valid Bech32 but not wallet addresses, so the parser
    // must not match them.
    const validBech32 = [
      'A12UEL5L',
      'a12uel5l',
      'an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs',
      'abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw',
      '11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j',
      'split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w',
      '?1ezyfcl',
    ];

    test('does not treat generic Bech32 strings as wallet addresses', () {
      validBech32.forEach(_expectNoMatch);
    });

    const invalidBech32 = [
      ' 1nwldj5',
      '\x7f1axkwrx',
      'an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx',
      'pzry9x0s0muk',
      '1pzry9x0s0muk',
      'x1b4n0q5v',
      'li1dgmt3',
      'de1lg7wt\xff',
      'A1G7SGD8',
      '10a06t8',
      '1qzzfhee',
    ];

    test('rejects every invalid Bech32 string without throwing', () {
      invalidBech32.forEach(_expectNoMatch);
    });
  });

  group('BIP 350 test vectors', () {
    // Source: https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki
    // sections "Test vectors for Bech32m" and "Test vectors for v0-v16 native
    // segregated witness addresses".
    const validSegwit = [
      'BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4',
      'tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7',
      'bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kt5nd6y',
      'BC1SW50QGDZ25J',
      'bc1zw508d6qejxtdg4y5r3zarvaryvaxxpcs',
      'tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy',
      'tb1pqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesf3hn0c',
      'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0',
    ];

    test('accepts Bech32m addresses for v1 and later versions', () {
      // BIP 350 recommends accepting v1 and higher so a future soft fork is
      // forward-compatible. P2TR is v1; v2 and v16 exercise the same path.
      expect(
        _match(validSegwit[2]).candidate.family,
        WalletAddressFamily.bitcoin,
      );
      expect(
        _match(validSegwit[3]).candidate.family,
        WalletAddressFamily.bitcoin,
      );
      expect(
        _match(validSegwit[4]).candidate.family,
        WalletAddressFamily.bitcoin,
      );
      expect(
        _match(validSegwit[7]).candidate.family,
        WalletAddressFamily.bitcoin,
      );
      expect(
        _match(validSegwit[7]).candidate.canonical,
        'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0',
      );

      for (final index in [1, 5, 6]) {
        expect(
          WalletAddressParser.parse(validSegwit[index]),
          isA<WalletAddressRefused>(),
        );
      }
      expect(
        _match(validSegwit[0]).candidate.family,
        WalletAddressFamily.bitcoin,
      );
    });

    const invalidSegwit = [
      'tc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq5zuyut',
      'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqh2y7hd',
      'tb1z0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqglt7rf',
      'BC1S0XLXVLHEMJA6C4DQV22UAPCTQUPFHLXM9H8Z3K2E72Q4K9HCZ7VQ54WELL',
      'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kemeawh',
      'tb1q0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq24jc47',
      'bc1p38j9r5y49hruaue7wxjce0updqjuyyx0kh56v8s25huc6995vvpql3jow4',
      'BC130XLXVLHEMJA6C4DQV22UAPCTQUPFHLXM9H8Z3K2E72Q4K9HCZ7VQ7ZWS8R',
      'bc1pw5dgrnzv',
      'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7v8n0nx0muaewav253zgeav',
      'BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P',
      'tb1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq47Zagq',
      'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7v07qwwzcrf',
      'tb1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vpggkg4j',
      'bc1gmk9yu',
    ];

    test('rejects every invalid v0-v16 address', () {
      invalidSegwit.forEach(_expectNoMatch);
    });

    const validBech32m = [
      'A1LQFN3A',
      'a1lqfn3a',
      'an83characterlonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11sg7hg6',
      'abcdef1l7aum6echk45nj3s0wdvt2fg8x9yrzpqzd3ryx',
      '11llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllludsr8',
      'split1checkupstagehandshakeupstreamerranterredcaperredlc445v',
      '?1v759aa',
    ];

    test('does not treat generic Bech32m strings as wallet addresses', () {
      validBech32m.forEach(_expectNoMatch);
    });

    const invalidBech32m = [
      ' 1xj0phk',
      '\x7f1g6xzxy',
      '\x801vctc34',
      'an84characterslonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11d6pts4',
      'qyrz8wqd2c9m',
      '1qyrz8wqd2c9m',
      'y1b0jsk6g',
      'lt1igcx5c0',
      'in1muywd',
      'mm1crxm3i',
      'au1s5cgom',
      'M1VUXWEZ',
      '16plkw9',
      '1p2gdwpf',
    ];

    test('rejects every invalid Bech32m string without throwing', () {
      invalidBech32m.forEach(_expectNoMatch);
    });
  });

  group('Bitcoin legacy addresses', () {
    test('accepts P2PKH and P2SH', () {
      const p2pkh = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';
      const p2sh = '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy';
      expect(_match(p2pkh).candidate.family, WalletAddressFamily.bitcoin);
      expect(_match(p2sh).candidate.family, WalletAddressFamily.bitcoin);
      expect(_match(p2pkh).candidate.canonical, p2pkh);
      expect(_match(p2sh).candidate.canonical, p2sh);
      expect(_match(p2pkh).candidate.display, '1Boa...tpyT');
    });

    test('rejects one changed character in a P2PKH address', () {
      expect(
        WalletAddressParser.parse('1BoatSLRHtKNngkdXEeobR76b53LETtpyU'),
        isA<WalletAddressInvalid>(),
      );
    });
  });

  group('EIP-55 test vectors', () {
    // Source: https://github.com/ethereum/ERCs/blob/master/ERCS/erc-55.md
    // section "Test Cases".
    const checksummed = [
      '0x52908400098527886E0F7030069857D2E4169EE7',
      '0x8617E340B3D01FA5F11F306F4090FD50E238070D',
      '0xde709f2102306220921060314715629080e2fb77',
      '0x27b1fdb04752bbc536007a920d24acb045561c26',
      '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed',
      '0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359',
      '0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB',
      '0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb',
    ];

    test('accepts every checksummed example and shows EIP-55', () {
      for (final input in checksummed) {
        final candidate = _match(input).candidate;
        expect(candidate.family, WalletAddressFamily.evm);
        expect(candidate.networks, contains('ethereumMainnet'));
        expect(candidate.networks, hasLength(7));
        expect(candidate.canonical, input.toLowerCase());
        expect(candidate.display, input);
        expect(candidate.kind, WalletAddressKind.address);
      }
    });

    test('accepts all-lower and all-upper input without a checksum', () {
      const mixed = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';
      final lower = _match(mixed.toLowerCase()).candidate;
      final upper = _match('0x${mixed.substring(2).toUpperCase()}').candidate;
      expect(lower.canonical, mixed.toLowerCase());
      expect(lower.display, mixed);
      expect(upper.canonical, mixed.toLowerCase());
      expect(upper.display, mixed);
    });

    test('rejects a mixed-case address with one wrong character', () {
      expect(
        WalletAddressParser.parse('0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAeD'),
        isA<WalletAddressInvalid>(),
      );
    });

    test('rejects a wrong length or a non-hex character', () {
      _expectNoMatch('0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAe');
      _expectNoMatch('0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed0');
      _expectNoMatch('0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAeZ');
    });
  });

  group('Tron', () {
    // The Tether TRC-20 contract, a well-known public address.
    const usdt = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t';
    const usdtHex = '41a614f803b6fd780986a42c78ec9c7f77e6ded13c';

    test('accepts a Base58Check T address', () {
      final candidate = _match(usdt).candidate;
      expect(candidate.family, WalletAddressFamily.tron);
      expect(candidate.networks, ['tronMainnet']);
      expect(candidate.canonical, usdt);
      expect(candidate.display, usdt);
    });

    test('accepts the 42-digit hex form and canonicalises it', () {
      final candidate = _match(usdtHex).candidate;
      expect(candidate.canonical, usdt);
      expect(candidate.display, usdt);
    });

    test('rejects one changed character', () {
      expect(
        WalletAddressParser.parse('TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6u'),
        isA<WalletAddressInvalid>(),
      );
    });
  });

  group('XRP Ledger', () {
    // The genesis account, published in the XRP Ledger documentation.
    const genesis = 'rHb9CJAWyB4rj91VRWn96DkukG4bwdtyTh';

    test('accepts a classic r address', () {
      final candidate = _match(genesis).candidate;
      expect(candidate.family, WalletAddressFamily.xrpl);
      expect(candidate.networks, ['xrplMainnet']);
      expect(candidate.canonical, genesis);
      expect(candidate.display, genesis);
    });

    test('accepts a mainnet X-address with no tag and decodes it', () {
      const xAddress = 'XVPcpSm47b1CZkf5AkKM9a84dQHe3m4sBhsrA4XtnBECTAc';
      final candidate = _match(xAddress).candidate;
      expect(candidate.canonical, genesis);
      expect(candidate.display, genesis);
    });

    test('rejects one changed character', () {
      expect(
        WalletAddressParser.parse('rHb9CJAWyB4rj91VRWn96DkukG4bwdtyTi'),
        isA<WalletAddressInvalid>(),
      );
    });
  });

  group('Bitcoin HD keys', () {
    // BIP 32 test vector 1, the master key at depth 0. Only the version bytes
    // matter to the parser; no derivation happens here.
    const xpub =
        'xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8';

    String hdIdentity(String basis) =>
        'hd:${sha256.convert(utf8.encode(basis)).toString().substring(0, 40)}';

    test('recognises xpub as an ambiguous HD key', () {
      final candidate = _match(xpub).candidate;
      expect(candidate.family, WalletAddressFamily.bitcoin);
      expect(candidate.networks, ['bitcoinMainnet']);
      expect(candidate.kind, WalletAddressKind.hdKey);
      expect(candidate.isHdKey, isTrue);
      expect(candidate.isScriptTypeAmbiguous, isTrue);
      expect(candidate.hdScriptType, isNull);
      expect(candidate.canonical, hdIdentity(xpub));
      expect(candidate.canonical, hasLength(43));
      expect(candidate.display, startsWith('xpub'));
    });

    test('recognises zpub as native SegWit and ypub as wrapped SegWit', () {
      // SLIP-132 version bytes from
      // https://github.com/satoshilabs/slips/blob/master/slip-0132.md.
      final zpub = reVersionExtendedKey(xpub, 0x04b24746);
      final ypub = reVersionExtendedKey(xpub, 0x049d7cb2);

      final zCandidate = _match(zpub).candidate;
      expect(zCandidate.hdScriptType, WalletAddressHdScriptType.wpkh);
      expect(
        zCandidate.canonical,
        hdIdentity('wpkh($xpub/<0;1>/*)'),
      );

      final yCandidate = _match(ypub).candidate;
      expect(yCandidate.hdScriptType, WalletAddressHdScriptType.shWpkh);
      expect(
        yCandidate.canonical,
        hdIdentity('sh(wpkh($xpub/<0;1>/*))'),
      );
    });

    test('rejects a changed key character', () {
      final changed = '${xpub.substring(0, xpub.length - 1)}9';
      expect(
        WalletAddressParser.parse(changed),
        isA<WalletAddressInvalid>(),
      );
    });
  });
}

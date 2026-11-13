/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

/// Which chain and network a wallet, holding, transaction or price is on.
/// Stored by name: append values, never rename one.
enum WalletNetwork implements _iss.SerializableModel {
  solanaMainnet,
  solanaDevnet,
  bitcoinMainnet,
  ethereumMainnet,
  baseMainnet,
  arbitrumOne,
  opMainnet,
  polygonPos,
  bnbSmartChain,
  avalancheCChain,
  tronMainnet,
  xrplMainnet,
  hyperliquid,
  dogecoinMainnet,
  litecoinMainnet,
  cardanoMainnet,
  tonMainnet,
  suiMainnet,
  aptosMainnet;

  static WalletNetwork fromJson(String name) {
    switch (name) {
      case 'solanaMainnet':
        return WalletNetwork.solanaMainnet;
      case 'solanaDevnet':
        return WalletNetwork.solanaDevnet;
      case 'bitcoinMainnet':
        return WalletNetwork.bitcoinMainnet;
      case 'ethereumMainnet':
        return WalletNetwork.ethereumMainnet;
      case 'baseMainnet':
        return WalletNetwork.baseMainnet;
      case 'arbitrumOne':
        return WalletNetwork.arbitrumOne;
      case 'opMainnet':
        return WalletNetwork.opMainnet;
      case 'polygonPos':
        return WalletNetwork.polygonPos;
      case 'bnbSmartChain':
        return WalletNetwork.bnbSmartChain;
      case 'avalancheCChain':
        return WalletNetwork.avalancheCChain;
      case 'tronMainnet':
        return WalletNetwork.tronMainnet;
      case 'xrplMainnet':
        return WalletNetwork.xrplMainnet;
      case 'hyperliquid':
        return WalletNetwork.hyperliquid;
      case 'dogecoinMainnet':
        return WalletNetwork.dogecoinMainnet;
      case 'litecoinMainnet':
        return WalletNetwork.litecoinMainnet;
      case 'cardanoMainnet':
        return WalletNetwork.cardanoMainnet;
      case 'tonMainnet':
        return WalletNetwork.tonMainnet;
      case 'suiMainnet':
        return WalletNetwork.suiMainnet;
      case 'aptosMainnet':
        return WalletNetwork.aptosMainnet;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "WalletNetwork"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

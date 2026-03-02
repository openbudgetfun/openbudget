import 'package:openbudget_server/src/auth/solana_wallet_auth_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

/// API surface for Solana wallet signature authentication.
class SolanaWalletAuthEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  /// Creates a one-time challenge message to be signed by the wallet.
  Future<SolanaWalletAuthChallengeResponse> createChallenge(
    Session session,
    String publicKeyBase64,
  ) async {
    return SolanaWalletAuthService.createChallenge(
      session,
      publicKeyBase64: publicKeyBase64,
    );
  }

  /// Verifies a signed challenge and returns Serverpod auth credentials.
  Future<AuthSuccess> login(
    Session session,
    UuidValue challengeId,
    String publicKeyBase64,
    String signedMessageBase64,
    String signatureBase64, {
    String? walletAddress,
  }) async {
    return SolanaWalletAuthService.login(
      session,
      challengeId: challengeId,
      publicKeyBase64: publicKeyBase64,
      signedMessageBase64: signedMessageBase64,
      signatureBase64: signatureBase64,
      walletAddress: walletAddress,
    );
  }
}

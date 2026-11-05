import 'dart:typed_data';

import 'package:openbudget_server/src/billing/billing_secrets.dart';
import 'package:openbudget_server/src/billing/solana_billing_chain.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_associated_token_account/solana_kit_associated_token_account.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';

/// Reads the Solana subscriptions program over JSON-RPC and submits collector
/// transfers with the configured keypair.
class SolanaRpcBillingChain implements SolanaBillingChain {
  SolanaRpcBillingChain({
    required String rpcUrl,
    required String collectorSecretKey,
    required String planAddress,
    required String usdcMint,
    Rpc? rpc,
  }) : _rpc = rpc ?? createSolanaRpc(url: rpcUrl),
       _planAddress = address(planAddress),
       _usdcMint = address(usdcMint),
       _collector = _createCollector(collectorSecretKey);

  factory SolanaRpcBillingChain.fromSession(Session session) =>
      SolanaRpcBillingChain(
        rpcUrl: BillingSecrets.require(
          session,
          BillingSecretKeys.solanaRpcUrl,
        ),
        collectorSecretKey: BillingSecrets.require(
          session,
          BillingSecretKeys.solanaCollectorSecretKey,
        ),
        planAddress: BillingSecrets.require(
          session,
          BillingSecretKeys.solanaSubscriptionPlanAddress,
        ),
        usdcMint: BillingSecrets.require(
          session,
          BillingSecretKeys.solanaUsdcMint,
        ),
      );

  final Rpc _rpc;
  final Address _planAddress;
  final Address _usdcMint;
  final KeyPairSigner _collector;

  @override
  Future<SolanaSubscriptionSnapshot?> fetchSubscription(
    String subscriptionAddress,
  ) async {
    final subscription = address(subscriptionAddress);
    final encoded = await _fetchEncoded(subscription);
    if (encoded == null) return null;
    if (encoded.programAddress != subscriptionsProgramAddress) return null;

    final SubscriptionDelegation delegation;
    try {
      delegation = decodeSubscriptionDelegation(encoded).data;
    } on Object {
      return null;
    }

    final (derived, _) = await findSubscriptionDelegationPda(
      programAddress: subscriptionsProgramAddress,
      seeds: SubscriptionDelegationSeeds(
        planPda: _planAddress,
        subscriber: delegation.header.delegator,
      ),
    );
    if (derived.value != subscription.value) return null;

    final planAccount = await _fetchEncoded(_planAddress);
    var planActive = false;
    if (planAccount != null &&
        planAccount.programAddress == subscriptionsProgramAddress) {
      try {
        final plan = decodePlan(planAccount).data;
        final nowSeconds = BigInt.from(
          DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
        );
        planActive =
            plan.status == PlanStatus.active.index &&
            plan.data.mint == _usdcMint &&
            plan.data.terms == delegation.terms &&
            (plan.data.endTs == BigInt.zero || plan.data.endTs > nowSeconds);
      } on Object {
        planActive = false;
      }
    }

    final nowSeconds = BigInt.from(
      DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
    );
    final subscriptionActive =
        delegation.expiresAtTs == BigInt.zero ||
        delegation.expiresAtTs > nowSeconds;

    return SolanaSubscriptionSnapshot(
      subscriptionAddress: subscription.value,
      planAddress: _planAddress.value,
      subscriberAddress: delegation.header.delegator.value,
      planActive: planActive,
      subscriptionActive: subscriptionActive,
      amountBaseUnits: delegation.terms.amount.toInt(),
      periodSeconds: (delegation.terms.periodHours * BigInt.from(3600)).toInt(),
    );
  }

  @override
  Future<void> transferSubscription({
    required String subscriptionAddress,
    required String planAddress,
    required String subscriberAddress,
    required String mintAddress,
    required int amountBaseUnits,
  }) async {
    try {
      final subscription = address(subscriptionAddress);
      final plan = address(planAddress);
      final subscriber = address(subscriberAddress);
      final mint = address(mintAddress);

      final (subscriptionAuthority, _) = await findSubscriptionAuthorityPda(
        programAddress: subscriptionsProgramAddress,
        seeds: SubscriptionAuthoritySeeds(user: subscriber, tokenMint: mint),
      );
      final (eventAuthority, _) = await findEventAuthorityPda(
        programAddress: subscriptionsProgramAddress,
      );
      final delegatorAta = getAssociatedTokenAddressSync(
        owner: subscriber,
        tokenProgram: tokenProgramAddress,
        mint: mint,
      );
      final receiverAta = getAssociatedTokenAddressSync(
        owner: _collector.address,
        tokenProgram: tokenProgramAddress,
        mint: mint,
      );

      final transfer = getTransferSubscriptionInstruction(
        programAddress: subscriptionsProgramAddress,
        subscriptionPda: subscription,
        planPda: plan,
        subscriptionAuthority: subscriptionAuthority,
        delegatorAta: delegatorAta,
        receiverAta: receiverAta,
        caller: _collector.address,
        tokenMint: mint,
        tokenProgram: tokenProgramAddress,
        eventAuthority: eventAuthority,
        selfProgram: subscriptionsProgramAddress,
        transferData: TransferData(
          amount: BigInt.from(amountBaseUnits),
          delegator: subscriber,
          mint: mint,
        ),
      );
      final createReceiverAta = getCreateAssociatedTokenIdempotentInstruction(
        programAddress: ataProgramAddress,
        payer: _collector.address,
        ata: receiverAta,
        owner: _collector.address,
        mint: mint,
        systemProgram: systemProgramAddress,
        tokenProgram: tokenProgramAddress,
      );

      final latestBlockhash = await _rpc.getLatestBlockhashValue().send();
      final message = createTransactionMessage(version: TransactionVersion.v0)
          .withFeePayer(_collector.address)
          .withBlockhashLifetime(
            BlockhashLifetimeConstraint(
              blockhash: latestBlockhash.value.blockhash.value,
              lastValidBlockHeight: latestBlockhash.value.lastValidBlockHeight,
            ),
          )
          .appendInstruction(createReceiverAta)
          .appendInstruction(transfer);
      final signed = await signTransactionMessageWithSigners(
        addSignersToTransactionMessage([_collector], message),
      );
      await sendAndConfirmTransaction(rpc: _rpc, transaction: signed);
    } on BillingProviderException {
      rethrow;
    } on Object catch (error) {
      throw BillingProviderException(
        provider: 'solana',
        details: error.runtimeType.toString(),
      );
    }
  }

  Future<EncodedAccount?> _fetchEncoded(Address address) async {
    final maybe = await fetchEncodedAccount(_rpc, address);
    if (maybe case ExistingAccount(:final account)) {
      return account;
    }
    return null;
  }

  static KeyPairSigner _createCollector(String secretKey) {
    final bytes = Uint8List.fromList(getBase58Encoder().encode(secretKey));
    if (bytes.length != 64) {
      throw BillingRailUnavailableException(
        message: '${BillingSecretKeys.solanaCollectorSecretKey} is invalid',
      );
    }
    return createSignerFromKeyPair(createKeyPairFromBytes(bytes));
  }
}

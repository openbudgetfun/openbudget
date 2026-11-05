import 'package:flutter/widgets.dart';
import 'package:openbudget_app/src/features/plus/models/plus_config.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_billing_api.dart';
import 'package:openbudget_app/src/features/plus/services/solana_subscribe_flow.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_associated_token_account/solana_kit_associated_token_account.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_ui/skribble.dart';

part 'solana_wallet_subscribe_flow.g.dart';

final _log = ObLogger('SolanaWalletSubscribeFlow');

/// Subscribes through a browser wallet, then proves ownership to the server.
///
/// The wallet approves one transaction that creates the subscription
/// authority (when needed) and the subscription delegation. Afterwards the
/// same wallet signs the server's one-time message so
/// `confirmSolanaSubscription` can record the entitlement.
class SolanaWalletSubscribeFlow implements SolanaSubscribeFlow {
  SolanaWalletSubscribeFlow(this._billing, {Rpc? rpc})
    : _rpc = rpc ?? createSolanaRpc(url: PlusConfig.solanaRpcUrl);

  final PlusBillingApi _billing;
  final Rpc _rpc;

  static final _appIdentity = WalletAppIdentity(
    name: PlusConfig.appName,
    uri: Uri.parse(PlusConfig.appUrl),
  );

  @override
  Future<void> subscribe({required BuildContext context}) async {
    final controller = WalletController(
      createDefaultWalletRegistry(
        appIdentity: _appIdentity,
        chain: PlusConfig.solanaChain,
      ),
      chain: PlusConfig.solanaChain,
    );

    try {
      final planView = await _billing.getSolanaPlan();
      final program = address(planView.programAddress);
      final planPda = address(planView.planAddress);
      final mint = address(planView.usdcMint);
      if (program != subscriptionsProgramAddress) {
        throw const SolanaSubscribeException(SolanaSubscribeFailure.failed);
      }

      final planAccount = await _fetchAccount(planPda);
      if (planAccount == null) {
        throw const SolanaSubscribeException(SolanaSubscribeFailure.failed);
      }
      final plan = decodePlan(planAccount).data;
      if (plan.status != PlanStatus.active.index || plan.data.mint != mint) {
        throw const SolanaSubscribeException(SolanaSubscribeFailure.failed);
      }

      await controller.initialize();
      if (controller.state.wallets.isEmpty) {
        throw const SolanaSubscribeException(
          SolanaSubscribeFailure.walletUnavailable,
        );
      }
      if (!controller.state.isConnected) {
        if (!context.mounted) {
          throw const SolanaSubscribeException(
            SolanaSubscribeFailure.walletRejected,
          );
        }
        final selected = await showSkribbleWalletPicker(
          context: context,
          controller: controller,
        );
        if (selected == null || !controller.state.isConnected) {
          throw const SolanaSubscribeException(
            SolanaSubscribeFailure.walletRejected,
          );
        }
      }

      final signer = controller.createSigner();
      await _ensureAuthority(signer, program, mint);
      final authorityInitId = await _authorityInitId(signer, program, mint);
      await _ensureSubscription(
        signer: signer,
        program: program,
        planPda: planPda,
        plan: plan,
        mint: mint,
        authorityInitId: authorityInitId,
      );
      await _confirmOwnership(signer);
    } on SolanaSubscribeException {
      rethrow;
    } on Object catch (error, stackTrace) {
      _log.warning(
        'subscribe.failed error=${error.runtimeType}',
        error,
        stackTrace,
      );
      throw SolanaSubscribeException(SolanaSubscribeFailure.failed, error);
    } finally {
      controller.dispose();
    }
  }

  Future<void> _ensureAuthority(
    WalletAccountSigner signer,
    Address program,
    Address mint,
  ) async {
    final authority = await _findAuthority(signer.address, program, mint);
    if (await _fetchAccount(authority) != null) return;

    final userAta = getAssociatedTokenAddressSync(
      owner: signer.address,
      tokenProgram: tokenProgramAddress,
      mint: mint,
    );
    final createAta = getCreateAssociatedTokenIdempotentInstruction(
      programAddress: ataProgramAddress,
      payer: signer.address,
      ata: userAta,
      owner: signer.address,
      mint: mint,
      systemProgram: systemProgramAddress,
      tokenProgram: tokenProgramAddress,
    );
    final initAuthority = getInitSubscriptionAuthorityInstruction(
      programAddress: program,
      owner: signer.address,
      subscriptionAuthority: authority,
      tokenMint: mint,
      userAta: userAta,
      systemProgram: systemProgramAddress,
      tokenProgram: tokenProgramAddress,
    );
    await _sendAndConfirm([createAta, initAuthority], signer);
  }

  Future<BigInt> _authorityInitId(
    WalletAccountSigner signer,
    Address program,
    Address mint,
  ) async {
    final authority = await _findAuthority(signer.address, program, mint);
    final account = await _fetchAccount(authority);
    if (account == null) {
      throw const SolanaSubscribeException(SolanaSubscribeFailure.failed);
    }
    return decodeSubscriptionAuthority(account).data.initId;
  }

  Future<void> _ensureSubscription({
    required WalletAccountSigner signer,
    required Address program,
    required Address planPda,
    required Plan plan,
    required Address mint,
    required BigInt authorityInitId,
  }) async {
    final (subscriptionPda, _) = await findSubscriptionDelegationPda(
      programAddress: program,
      seeds: SubscriptionDelegationSeeds(
        planPda: planPda,
        subscriber: signer.address,
      ),
    );
    if (await _fetchAccount(subscriptionPda) != null) return;

    final (authority, _) = await findSubscriptionAuthorityPda(
      programAddress: program,
      seeds: SubscriptionAuthoritySeeds(
        user: signer.address,
        tokenMint: mint,
      ),
    );
    final (eventAuthority, _) = await findEventAuthorityPda(
      programAddress: program,
    );
    final subscribe = getSubscribeInstruction(
      programAddress: program,
      subscriber: signer.address,
      merchant: plan.owner,
      planPda: planPda,
      subscriptionPda: subscriptionPda,
      subscriptionAuthorityPda: authority,
      systemProgram: systemProgramAddress,
      eventAuthority: eventAuthority,
      selfProgram: program,
      subscribeData: SubscribeData(
        planId: plan.data.planId,
        planBump: plan.bump,
        expectedMint: plan.data.mint,
        expectedAmount: plan.data.terms.amount,
        expectedPeriodHours: plan.data.terms.periodHours,
        expectedCreatedAt: plan.data.terms.createdAt,
        expectedSubscriptionAuthorityInitId: authorityInitId,
      ),
    );
    await _sendAndConfirm([subscribe], signer);
  }

  Future<void> _confirmOwnership(WalletAccountSigner signer) async {
    final challenge = await _billing.solanaSubscriptionChallenge();
    final signed = await signer.modifyAndSignMessages([
      createSignableMessage(challenge),
    ]);
    final signature = signed.single.signatures[signer.address];
    if (signature == null) {
      throw const SolanaSubscribeException(SolanaSubscribeFailure.failed);
    }
    await _billing.confirmSolanaSubscription(
      signer.address.value,
      challenge,
      getBase58Decoder().decode(signature.value),
    );
  }

  Future<void> _sendAndConfirm(
    List<Instruction> instructions,
    WalletAccountSigner signer,
  ) async {
    final latestBlockhash = await _rpc.getLatestBlockhashValue().send();
    var message = createTransactionMessage(version: TransactionVersion.v0)
        .withFeePayer(signer.address)
        .withBlockhashLifetime(
          BlockhashLifetimeConstraint(
            blockhash: latestBlockhash.value.blockhash.value,
            lastValidBlockHeight: latestBlockhash.value.lastValidBlockHeight,
          ),
        );
    for (final instruction in instructions) {
      message = message.appendInstruction(instruction);
    }
    final signed = await signTransactionMessageWithSigners(
      addSignersToTransactionMessage([signer], message),
    );
    await sendAndConfirmTransaction(rpc: _rpc, transaction: signed);
  }

  Future<Address> _findAuthority(
    Address user,
    Address program,
    Address mint,
  ) async {
    final (authority, _) = await findSubscriptionAuthorityPda(
      programAddress: program,
      seeds: SubscriptionAuthoritySeeds(user: user, tokenMint: mint),
    );
    return authority;
  }

  Future<EncodedAccount?> _fetchAccount(Address target) async {
    final maybe = await fetchEncodedAccount(_rpc, target);
    if (maybe case ExistingAccount(:final account)) return account;
    return null;
  }
}

/// The Solana flow the Plus screen uses. Only web offers the Solana rail.
@Riverpod(keepAlive: true)
SolanaSubscribeFlow solanaSubscribeFlow(Ref ref) =>
    SolanaWalletSubscribeFlow(ref.watch(plusBillingApiProvider));

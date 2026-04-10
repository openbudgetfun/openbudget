import 'package:openbudget_server/src/solana_wallets/solana_transaction_interpreter.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  const walletAddress = 'Wallet1111111111111111111111111111111111';

  group('SolanaTransactionInterpreter', () {
    test('uses provider description with high confidence', () {
      final tx = _buildTx(description: 'Swapped SOL for USDC');

      final interpreted = SolanaTransactionInterpreter.interpret(
        transaction: tx,
        walletAddress: walletAddress,
      );

      expect(interpreted.description, 'Swapped SOL for USDC');
      expect(interpreted.confidence, 'high');
    });

    test('identifies jupiter swaps with high confidence', () {
      final tx = _buildTx(
        source: 'jupiter',
        tokenTransfers: const [
          TokenTransfer(
            fromUserAccount: walletAddress,
            toUserAccount: 'Counterparty11111111111111111111111111111',
            fromTokenAccount: 'FromToken111111111111111111111111111111',
            toTokenAccount: 'ToToken11111111111111111111111111111111',
            tokenAmount: 1000000,
            mint: 'MintA111111111111111111111111111111111111',
            tokenStandard: 'Fungible',
          ),
          TokenTransfer(
            fromUserAccount: 'Counterparty11111111111111111111111111111',
            toUserAccount: walletAddress,
            fromTokenAccount: 'FromToken222222222222222222222222222222',
            toTokenAccount: 'ToToken22222222222222222222222222222222',
            tokenAmount: 500000,
            mint: 'MintB111111111111111111111111111111111111',
            tokenStandard: 'Fungible',
          ),
        ],
        instructions: const [
          InnerInstruction(
            accounts: [],
            data: '00',
            programId: 'JUP4Fb2cqiRUcaTHdrPC8h2gNsA2ETXiPDD33WcGuJB',
          ),
        ],
      );

      final interpreted = SolanaTransactionInterpreter.interpret(
        transaction: tx,
        walletAddress: walletAddress,
      );

      expect(interpreted.description, contains('Token swap on Jupiter'));
      expect(interpreted.confidence, 'high');
    });

    test('identifies pump.fun trades with high confidence', () {
      final tx = _buildTx(
        source: 'pumpfun',
        tokenTransfers: const [
          TokenTransfer(
            fromUserAccount: walletAddress,
            toUserAccount: 'Counterparty11111111111111111111111111111',
            fromTokenAccount: 'FromToken111111111111111111111111111111',
            toTokenAccount: 'ToToken11111111111111111111111111111111',
            tokenAmount: 250000,
            mint: 'PumpMint1111111111111111111111111111111111',
            tokenStandard: 'Fungible',
          ),
        ],
      );

      final interpreted = SolanaTransactionInterpreter.interpret(
        transaction: tx,
        walletAddress: walletAddress,
      );

      expect(interpreted.description, contains('Trade on Pump.fun'));
      expect(interpreted.confidence, 'high');
    });

    test('identifies raydium swaps with high confidence', () {
      final tx = _buildTx(
        source: 'raydium',
        tokenTransfers: const [
          TokenTransfer(
            fromUserAccount: walletAddress,
            toUserAccount: 'Pool111111111111111111111111111111111111',
            fromTokenAccount: 'FromToken111111111111111111111111111111',
            toTokenAccount: 'ToToken11111111111111111111111111111111',
            tokenAmount: 1000000,
            mint: 'MintA111111111111111111111111111111111111',
            tokenStandard: 'Fungible',
          ),
          TokenTransfer(
            fromUserAccount: 'Pool111111111111111111111111111111111111',
            toUserAccount: walletAddress,
            fromTokenAccount: 'FromToken222222222222222222222222222222',
            toTokenAccount: 'ToToken22222222222222222222222222222222',
            tokenAmount: 950000,
            mint: 'MintB111111111111111111111111111111111111',
            tokenStandard: 'Fungible',
          ),
        ],
      );

      final interpreted = SolanaTransactionInterpreter.interpret(
        transaction: tx,
        walletAddress: walletAddress,
      );

      expect(interpreted.description, contains('Token swap on Raydium'));
      expect(interpreted.confidence, 'high');
    });

    test('identifies orca swaps with high confidence', () {
      final tx = _buildTx(
        source: 'orca',
        tokenTransfers: const [
          TokenTransfer(
            fromUserAccount: walletAddress,
            toUserAccount: 'Pool111111111111111111111111111111111111',
            fromTokenAccount: 'FromToken111111111111111111111111111111',
            toTokenAccount: 'ToToken11111111111111111111111111111111',
            tokenAmount: 700000,
            mint: 'MintA111111111111111111111111111111111111',
            tokenStandard: 'Fungible',
          ),
          TokenTransfer(
            fromUserAccount: 'Pool111111111111111111111111111111111111',
            toUserAccount: walletAddress,
            fromTokenAccount: 'FromToken222222222222222222222222222222',
            toTokenAccount: 'ToToken22222222222222222222222222222222',
            tokenAmount: 680000,
            mint: 'MintB111111111111111111111111111111111111',
            tokenStandard: 'Fungible',
          ),
        ],
      );

      final interpreted = SolanaTransactionInterpreter.interpret(
        transaction: tx,
        walletAddress: walletAddress,
      );

      expect(interpreted.description, contains('Token swap on Orca'));
      expect(interpreted.confidence, 'high');
    });

    test('identifies nft purchase flow with high confidence', () {
      final tx = _buildTx(
        source: 'magiceden',
        nativeTransfers: const [
          NativeTransfer(
            fromUserAccount: walletAddress,
            toUserAccount: 'Marketplace1111111111111111111111111111111',
            amount: 1500000000,
          ),
        ],
        tokenTransfers: const [
          TokenTransfer(
            fromUserAccount: 'Marketplace1111111111111111111111111111111',
            toUserAccount: walletAddress,
            fromTokenAccount: 'FromTokenNFT1111111111111111111111111111',
            toTokenAccount: 'ToTokenNFT111111111111111111111111111111',
            tokenAmount: 1,
            mint: 'NftMint11111111111111111111111111111111111',
            tokenStandard: 'NonFungible',
          ),
        ],
      );

      final interpreted = SolanaTransactionInterpreter.interpret(
        transaction: tx,
        walletAddress: walletAddress,
      );

      expect(interpreted.description, contains('NFT purchase on Magic Eden'));
      expect(interpreted.description, contains('SOL out 1.5 SOL'));
      expect(interpreted.confidence, 'high');
    });

    test('classifies directional SOL transfer with medium confidence', () {
      final tx = _buildTx(
        nativeTransfers: const [
          NativeTransfer(
            fromUserAccount: walletAddress,
            toUserAccount: 'Friend111111111111111111111111111111111',
            amount: 5000000,
          ),
        ],
      );

      final interpreted = SolanaTransactionInterpreter.interpret(
        transaction: tx,
        walletAddress: walletAddress,
      );

      expect(interpreted.description, startsWith('SOL transfer sent'));
      expect(interpreted.description, contains('SOL out 0.005 SOL'));
      expect(interpreted.confidence, 'medium');
    });

    test('falls back to generic description with low confidence', () {
      final tx = _buildTx(type: 'UNKNOWN_ACTION', source: 'custom_source');

      final interpreted = SolanaTransactionInterpreter.interpret(
        transaction: tx,
        walletAddress: walletAddress,
      );

      expect(
        interpreted.description,
        contains('Unknown Action via custom_source'),
      );
      expect(interpreted.confidence, 'low');
    });
  });
}

EnhancedTransaction _buildTx({
  String? description,
  String type = 'TRANSFER',
  String source = 'system_program',
  List<NativeTransfer> nativeTransfers = const [],
  List<TokenTransfer> tokenTransfers = const [],
  List<InnerInstruction> instructions = const [],
}) => EnhancedTransaction(
    description: description,
    type: type,
    source: source,
    fee: 5000,
    feePayer: 0,
    signature: 'Sig11111111111111111111111111111111111111111111111111',
    slot: 1,
    timestamp: 1700000000,
    nativeTransfers: nativeTransfers,
    tokenTransfers: tokenTransfers,
    accountData: const [],
    instructions: instructions,
    events: const {},
  );

import 'package:solana_kit_helius/solana_kit_helius.dart';

class SolanaTransactionInterpretation {
  const SolanaTransactionInterpretation({
    required this.description,
    required this.confidence,
  });

  final String description;
  final String confidence;
}

class SolanaTransactionInterpreter {
  static SolanaTransactionInterpretation interpret({
    required EnhancedTransaction transaction,
    required String walletAddress,
  }) {
    final directDescription = transaction.description?.trim();
    if (directDescription != null && directDescription.isNotEmpty) {
      return SolanaTransactionInterpretation(
        description: directDescription,
        confidence: 'high',
      );
    }

    final flow = _walletFlow(transaction, walletAddress);
    final source = _friendlySource(transaction.source);

    final programLabels = transaction.instructions
        .map((instruction) => _friendlyProgram(instruction.programId))
        .where((label) => label != null)
        .cast<String>()
        .toSet()
        .toList(growable: false);

    final normalizedSource = transaction.source.toLowerCase();
    final hasJupiter =
        normalizedSource.contains('jup') || programLabels.contains('Jupiter');
    final hasPump =
        normalizedSource.contains('pump') || programLabels.contains('Pump.fun');
    final hasNftMarketplace =
        normalizedSource.contains('magiceden') ||
        normalizedSource.contains('tensor');
    final hasSwapSignals = flow.tokenIn > 0 && flow.tokenOut > 0;

    String action;
    var confidence = 'low';
    if (hasJupiter || hasSwapSignals) {
      action = hasJupiter ? 'Token swap on Jupiter' : 'Token swap';
      confidence = hasJupiter ? 'high' : 'medium';
    } else if (hasPump) {
      action = 'Trade on Pump.fun';
      confidence = 'high';
    } else if (hasNftMarketplace) {
      action = 'NFT activity on $source';
      confidence = 'high';
    } else if (flow.tokenOut > 0 && flow.tokenIn == 0 && flow.nativeIn == 0) {
      action = 'Token transfer sent';
      confidence = 'medium';
    } else if (flow.tokenIn > 0 && flow.tokenOut == 0 && flow.nativeOut == 0) {
      action = 'Token transfer received';
      confidence = 'medium';
    } else if (flow.nativeOut > 0 && flow.nativeIn == 0 && flow.tokenIn == 0) {
      action = 'SOL transfer sent';
      confidence = 'medium';
    } else if (flow.nativeIn > 0 && flow.nativeOut == 0 && flow.tokenOut == 0) {
      action = 'SOL transfer received';
      confidence = 'medium';
    } else {
      final readableType = transaction.type
          .toLowerCase()
          .replaceAll('_', ' ')
          .replaceAllMapped(RegExp(r'\b\w'), (match) {
            return match.group(0)!.toUpperCase();
          });
      action = '$readableType via $source';
    }

    final transferSummary = _walletFlowSummary(flow);
    final shortProgramLabels = programLabels.take(2).toList(growable: false);
    final remainingPrograms = programLabels.length - shortProgramLabels.length;
    final programSummary = shortProgramLabels.isEmpty
        ? ''
        : ' using ${shortProgramLabels.join(', ')}'
              '${remainingPrograms > 0 ? ' +$remainingPrograms' : ''}';

    return SolanaTransactionInterpretation(
      description: '$action$transferSummary$programSummary',
      confidence: confidence,
    );
  }

  static ({int nativeIn, int nativeOut, int tokenIn, int tokenOut}) _walletFlow(
    EnhancedTransaction tx,
    String walletAddress,
  ) {
    var nativeIn = 0;
    var nativeOut = 0;
    for (final transfer in tx.nativeTransfers) {
      if (transfer.toUserAccount == walletAddress) nativeIn += 1;
      if (transfer.fromUserAccount == walletAddress) nativeOut += 1;
    }

    var tokenIn = 0;
    var tokenOut = 0;
    for (final transfer in tx.tokenTransfers) {
      if (transfer.toUserAccount == walletAddress) tokenIn += 1;
      if (transfer.fromUserAccount == walletAddress) tokenOut += 1;
    }

    return (
      nativeIn: nativeIn,
      nativeOut: nativeOut,
      tokenIn: tokenIn,
      tokenOut: tokenOut,
    );
  }

  static String _walletFlowSummary(
    ({int nativeIn, int nativeOut, int tokenIn, int tokenOut}) flow,
  ) {
    final segments = <String>[];
    if (flow.nativeIn > 0) segments.add('${flow.nativeIn} SOL in');
    if (flow.nativeOut > 0) segments.add('${flow.nativeOut} SOL out');
    if (flow.tokenIn > 0) segments.add('${flow.tokenIn} token in');
    if (flow.tokenOut > 0) segments.add('${flow.tokenOut} token out');
    if (segments.isEmpty) return '';
    return ' (${segments.join(', ')})';
  }

  static String _friendlySource(String source) {
    final normalized = source.toLowerCase();
    return switch (normalized) {
      'jupiter' => 'Jupiter',
      'pumpfun' => 'Pump.fun',
      'magiceden' => 'Magic Eden',
      'tensor' => 'Tensor',
      'system_program' => 'System Program',
      'token_program' => 'SPL Token Program',
      'token_2022' => 'SPL Token 2022 Program',
      _ => source,
    };
  }

  static String? _friendlyProgram(String? programId) {
    if (programId == null) return null;
    final normalized = programId.trim();
    if (normalized.isEmpty) return null;

    if (normalized == '11111111111111111111111111111111') {
      return 'System Program';
    }
    if (normalized.startsWith('TokenkegQfe')) return 'SPL Token';
    if (normalized.startsWith('TokenzQd')) return 'Token-2022';
    if (normalized.startsWith('AToken')) return 'Associated Token';
    if (normalized.startsWith('ComputeBudget')) return 'Compute Budget';
    if (normalized.startsWith('MemoSq4')) return 'Memo Program';
    if (normalized.startsWith('JUP') ||
        normalized.toLowerCase().contains('jup')) {
      return 'Jupiter';
    }
    if (normalized.startsWith('6EF8rrecthR') ||
        normalized.toLowerCase().contains('pump')) {
      return 'Pump.fun';
    }
    if (normalized.startsWith('metaqbxx')) return 'Metaplex Metadata';
    if (normalized.startsWith('whirLbM')) return 'Orca Whirlpool';
    if (normalized.startsWith('9W959DqE')) return 'Raydium';
    return null;
  }
}

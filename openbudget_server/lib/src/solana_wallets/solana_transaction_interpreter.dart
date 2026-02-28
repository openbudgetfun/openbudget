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
    final hasRaydium =
        normalizedSource.contains('raydium') ||
        programLabels.contains('Raydium');
    final hasOrca =
        normalizedSource.contains('orca') ||
        programLabels.any((label) => label.contains('Orca'));
    final hasPump =
        normalizedSource.contains('pump') || programLabels.contains('Pump.fun');
    final hasNftMarketplace =
        normalizedSource.contains('magiceden') ||
        normalizedSource.contains('tensor');
    final hasSwapSignals = flow.tokenInCount > 0 && flow.tokenOutCount > 0;
    final normalizedType = transaction.type.toLowerCase();

    String action;
    var confidence = 'low';
    if (hasJupiter || hasRaydium || hasOrca || hasSwapSignals) {
      if (hasJupiter) {
        action = 'Token swap on Jupiter';
        confidence = 'high';
      } else if (hasRaydium) {
        action = 'Token swap on Raydium';
        confidence = 'high';
      } else if (hasOrca) {
        action = 'Token swap on Orca';
        confidence = 'high';
      } else {
        action = 'Token swap';
        confidence = 'medium';
      }
    } else if (hasPump) {
      action = 'Trade on Pump.fun';
      confidence = 'high';
    } else if (hasNftMarketplace) {
      final looksLikeBuy =
          flow.nativeOutCount > 0 &&
          flow.nativeInCount == 0 &&
          flow.tokenInCount > 0;
      final looksLikeSell =
          flow.nativeInCount > 0 &&
          flow.nativeOutCount == 0 &&
          flow.tokenOutCount > 0;
      if (looksLikeBuy) {
        action = 'NFT purchase on $source';
      } else if (looksLikeSell) {
        action = 'NFT sale on $source';
      } else {
        action = 'NFT activity on $source';
      }
      confidence = 'high';
    } else if (normalizedType.contains('stake')) {
      action = 'Staking activity';
      confidence = 'medium';
    } else if (normalizedType.contains('liquidity')) {
      action = 'Liquidity position update';
      confidence = 'medium';
    } else if (flow.tokenOutCount > 0 &&
        flow.tokenInCount == 0 &&
        flow.nativeInCount == 0) {
      action = 'Token transfer sent';
      confidence = 'medium';
    } else if (flow.tokenInCount > 0 &&
        flow.tokenOutCount == 0 &&
        flow.nativeOutCount == 0) {
      action = 'Token transfer received';
      confidence = 'medium';
    } else if (flow.nativeOutCount > 0 &&
        flow.nativeInCount == 0 &&
        flow.tokenInCount == 0) {
      action = 'SOL transfer sent';
      confidence = 'medium';
    } else if (flow.nativeInCount > 0 &&
        flow.nativeOutCount == 0 &&
        flow.tokenOutCount == 0) {
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

  static ({
    int nativeInCount,
    int nativeOutCount,
    int nativeInLamports,
    int nativeOutLamports,
    int tokenInCount,
    int tokenOutCount,
  })
  _walletFlow(EnhancedTransaction tx, String walletAddress) {
    var nativeInCount = 0;
    var nativeOutCount = 0;
    var nativeInLamports = 0;
    var nativeOutLamports = 0;
    for (final transfer in tx.nativeTransfers) {
      if (transfer.toUserAccount == walletAddress) {
        nativeInCount += 1;
        nativeInLamports += transfer.amount;
      }
      if (transfer.fromUserAccount == walletAddress) {
        nativeOutCount += 1;
        nativeOutLamports += transfer.amount;
      }
    }

    var tokenInCount = 0;
    var tokenOutCount = 0;
    for (final transfer in tx.tokenTransfers) {
      if (transfer.toUserAccount == walletAddress) tokenInCount += 1;
      if (transfer.fromUserAccount == walletAddress) tokenOutCount += 1;
    }

    return (
      nativeInCount: nativeInCount,
      nativeOutCount: nativeOutCount,
      nativeInLamports: nativeInLamports,
      nativeOutLamports: nativeOutLamports,
      tokenInCount: tokenInCount,
      tokenOutCount: tokenOutCount,
    );
  }

  static String _walletFlowSummary(
    ({
      int nativeInCount,
      int nativeOutCount,
      int nativeInLamports,
      int nativeOutLamports,
      int tokenInCount,
      int tokenOutCount,
    })
    flow,
  ) {
    final segments = <String>[];
    if (flow.nativeInCount > 0) {
      segments.add('SOL in ${_formatLamports(flow.nativeInLamports)}');
    }
    if (flow.nativeOutCount > 0) {
      segments.add('SOL out ${_formatLamports(flow.nativeOutLamports)}');
    }
    if (flow.tokenInCount > 0) {
      segments.add('${flow.tokenInCount} token in');
    }
    if (flow.tokenOutCount > 0) {
      segments.add('${flow.tokenOutCount} token out');
    }
    if (segments.isEmpty) return '';
    return ' (${segments.join(', ')})';
  }

  static String _formatLamports(int lamports) {
    final sol = lamports / 1000000000;
    var formatted = sol.toStringAsFixed(sol.abs() >= 1 ? 4 : 6);
    formatted = formatted.replaceFirst(RegExp(r'0+$'), '');
    formatted = formatted.replaceFirst(RegExp(r'\.$'), '');
    return '$formatted SOL';
  }

  static String _friendlySource(String source) {
    final normalized = source.toLowerCase();
    return switch (normalized) {
      'jupiter' => 'Jupiter',
      'raydium' => 'Raydium',
      'orca' => 'Orca',
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

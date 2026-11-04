/// Prices for the built-in OpenCode Zen provider, in micro-dollars per
/// million tokens.
abstract final class AgentPricing {
  /// Uncached input tokens.
  static const int inputMicroUsdPerMillionTokens = 300000;

  /// Cached input tokens, which the provider bills far cheaper.
  static const int cachedInputMicroUsdPerMillionTokens = 6000;

  /// Completion tokens.
  static const int outputMicroUsdPerMillionTokens = 1200000;

  static const int _tokensPerMillion = 1000000;

  /// Returns the cost of one call in micro-dollars, rounded up.
  ///
  /// A micro-dollar is a millionth of a US dollar, so multiplying the token
  /// counts by the per-million prices gives the numerator directly. Integer
  /// math keeps the charge exact at these small amounts.
  static int costMicroUsd({
    required int promptTokens,
    required int cachedTokens,
    required int completionTokens,
  }) {
    final prompt = promptTokens < 0 ? 0 : promptTokens;
    final completion = completionTokens < 0 ? 0 : completionTokens;
    final cached = cachedTokens < 0
        ? 0
        : (cachedTokens > prompt ? prompt : cachedTokens);
    final uncached = prompt - cached;

    final numerator =
        uncached * inputMicroUsdPerMillionTokens +
        cached * cachedInputMicroUsdPerMillionTokens +
        completion * outputMicroUsdPerMillionTokens;
    if (numerator == 0) return 0;
    return (numerator + _tokensPerMillion - 1) ~/ _tokensPerMillion;
  }
}

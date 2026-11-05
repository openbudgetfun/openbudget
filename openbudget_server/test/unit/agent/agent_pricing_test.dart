import 'package:openbudget_server/src/agent/agent_pricing.dart';
import 'package:test/test.dart';

void main() {
  group('Given AgentPricing', () {
    test('then uncached input, cached input and output are priced apart', () {
      // 800 x 300000 + 200 x 6000 + 500 x 1200000 = 841200000, rounded up.
      expect(
        AgentPricing.costMicroUsd(
          promptTokens: 1000,
          cachedTokens: 200,
          completionTokens: 500,
        ),
        842,
      );
    });

    test('then an absent cached token count is treated as zero', () {
      expect(
        AgentPricing.costMicroUsd(
          promptTokens: 1000,
          cachedTokens: 0,
          completionTokens: 0,
        ),
        300,
      );
    });

    test('then a fraction of a micro-dollar rounds up', () {
      expect(
        AgentPricing.costMicroUsd(
          promptTokens: 0,
          cachedTokens: 0,
          completionTokens: 1,
        ),
        2,
      );
    });

    test('then a zero-token call costs nothing', () {
      expect(
        AgentPricing.costMicroUsd(
          promptTokens: 0,
          cachedTokens: 0,
          completionTokens: 0,
        ),
        0,
      );
    });

    test('then cached tokens above the prompt are clamped', () {
      expect(
        AgentPricing.costMicroUsd(
          promptTokens: 100,
          cachedTokens: 500,
          completionTokens: 0,
        ),
        AgentPricing.costMicroUsd(
          promptTokens: 100,
          cachedTokens: 100,
          completionTokens: 0,
        ),
      );
    });

    test('then negative token counts never make a call cheaper', () {
      expect(
        AgentPricing.costMicroUsd(
          promptTokens: -5,
          cachedTokens: -5,
          completionTokens: -5,
        ),
        0,
      );
    });

    test('then the first micro-dollar is charged exactly at three and a '
        'third million input tokens', () {
      expect(
        AgentPricing.costMicroUsd(
          promptTokens: 3333333,
          cachedTokens: 0,
          completionTokens: 0,
        ),
        1000000,
      );
    });
  });
}

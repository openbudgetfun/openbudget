import 'package:openbudget_server/src/billing/billing_plan.dart';
import 'package:openbudget_server/src/billing/solana_billing_plan.dart';
import 'package:test/test.dart';

void main() {
  group('Given BillingPlan', () {
    test('then Plus costs twenty dollars a month', () {
      expect(BillingPlan.monthlyPriceUsdCents, 2000);
    });

    test('then each period includes five dollars of agent usage', () {
      expect(BillingPlan.includedAgentUsageMicroUsd, 5_000_000);
    });
  });

  group('Given SolanaBillingPlan', () {
    test('then each period charges twenty USDC in base units', () {
      expect(SolanaBillingPlan.amountBaseUnits, 20_000_000);
    });

    test('then each period runs for thirty days', () {
      expect(SolanaBillingPlan.periodSeconds, 30 * 24 * 60 * 60);
      expect(SolanaBillingPlan.periodHours, 30 * 24);
    });
  });
}

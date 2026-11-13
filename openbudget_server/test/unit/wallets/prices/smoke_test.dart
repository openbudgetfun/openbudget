import 'package:openbudget_server/src/wallets/prices/coingecko_price_client.dart';
import 'package:openbudget_server/src/wallets/prices/defillama_price_client.dart';
import 'package:openbudget_server/src/wallets/prices/price_service.dart';
import 'package:test/test.dart';

void main() {
  test('smoke', () {
    expect(CoinGeckoPriceClient.chunkSize, 515);
    expect(DefiLlamaPriceClient.confidenceThreshold, 0.9);
    expect(PriceService.defiLlamaConfidenceThreshold, 0.9);
  });
}

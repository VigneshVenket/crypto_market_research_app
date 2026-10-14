import 'package:crypto_market_research_app/data/api/api_provider.dart';
import 'package:crypto_market_research_app/data/response/crypto/coin_chart_response.dart';
import 'package:crypto_market_research_app/data/response/crypto/coin_market_response.dart';
import 'package:crypto_market_research_app/data/response/crypto/global_market_response.dart';

class CryptoRepo {
  final ApiProvider apiProvider = ApiProvider();

  Future<CoinMarketResponse> fetchCoins() {
    return apiProvider.fetchCoins();
  }

  Future<CoinChartResponse> fetchCoinChart({
    required String coinId,
    required int days,
  }) {
    return apiProvider.fetchCoinChart(coinId: coinId, days: days);
  }


  Future<GlobalMarketResponse> fetchGlobalMarket() async {
    return await apiProvider.fetchGlobalMarket();
  }

  Future<CoinMarketResponse> fetchWatchlistMarketData({
    required List<String> coinIds,
  }) async {
    return await apiProvider.fetchWatchlistMarketData(
      coinIds: coinIds,
    );
  }
}

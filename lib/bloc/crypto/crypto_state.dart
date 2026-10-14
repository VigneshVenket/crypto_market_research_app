import 'package:crypto_market_research_app/data/response/crypto/coin_market_response.dart';
import 'package:crypto_market_research_app/data/response/crypto/coin_chart_response.dart';
import 'package:crypto_market_research_app/data/response/crypto/global_market_response.dart';

abstract class CryptoState {
  final CoinMarketResponse? coinsResponse;
  final CoinChartResponse? chartResponse;
  final String? chartCoinId;
  final GlobalMarketResponse? globalMarketResponse;
  final CoinMarketResponse? watchlistResponse;

  const CryptoState({
    this.coinsResponse,
    this.chartResponse,
    this.chartCoinId,
    this.globalMarketResponse,
    this.watchlistResponse,
  });
}

class CryptoInitial extends CryptoState {
  const CryptoInitial();
}

class CryptoLoading extends CryptoState {
  final String loadingFor;

  const CryptoLoading({
    required this.loadingFor,
    super.coinsResponse,
    super.chartResponse,
    super.chartCoinId,
    super.globalMarketResponse,
    super.watchlistResponse,
  });
}

class CryptoError extends CryptoState {
  final String message;
  final String errorFor;

  const CryptoError(
    this.message,
    this.errorFor, {
    super.coinsResponse,
    super.chartResponse,
    super.chartCoinId,
    super.globalMarketResponse,
    super.watchlistResponse,
  });
}

class CryptoCoinsSuccess extends CryptoState {
  final CoinMarketResponse response;

  const CryptoCoinsSuccess(
    this.response, {
    super.chartResponse,
    super.chartCoinId,
    super.globalMarketResponse,
    super.watchlistResponse,
  }) : super(coinsResponse: response);
}

class CryptoChartSuccess extends CryptoState {
  final CoinChartResponse response;

  const CryptoChartSuccess({
    required this.response,
    required String coinId,
    required super.coinsResponse,
    super.globalMarketResponse,
    super.watchlistResponse,
  }) : super(chartResponse: response, chartCoinId: coinId);
}

class CryptoMarketStatsSuccess extends CryptoState {
  final GlobalMarketResponse response;

  const CryptoMarketStatsSuccess({
    required this.response,
    required CoinMarketResponse? coinsResponse,
    CoinChartResponse? chartResponse,
    String? chartCoinId,
    CoinMarketResponse? watchlistResponse,
  }) : super(
         coinsResponse: coinsResponse,
         chartResponse: chartResponse,
         chartCoinId: chartCoinId,
         globalMarketResponse: response,
         watchlistResponse: watchlistResponse,
       );
}

class CryptoWatchlistSuccess extends CryptoState {
  final CoinMarketResponse response;

  const CryptoWatchlistSuccess({
    required this.response,
    required CoinMarketResponse? coinsResponse,
    CoinChartResponse? chartResponse,
    String? chartCoinId,
    GlobalMarketResponse? globalMarketResponse,
  }) : super(
         coinsResponse: coinsResponse,
         chartResponse: chartResponse,
         chartCoinId: chartCoinId,
         globalMarketResponse: globalMarketResponse,
         watchlistResponse: response,
       );
}


class WatchlistUpdateSuccess extends CryptoState {
  final String coinId;
  final bool isAdded;
  final String message;

  const WatchlistUpdateSuccess({
    required this.coinId,
    required this.isAdded,
    required this.message,
    super.coinsResponse,
    super.chartResponse,
    super.chartCoinId,
    super.globalMarketResponse,
    super.watchlistResponse,
  });
}
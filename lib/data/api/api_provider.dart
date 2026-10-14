import 'package:crypto_market_research_app/data/response/crypto/global_market_response.dart';
import 'package:dio/dio.dart';
import 'package:crypto_market_research_app/data/response/crypto/coin_chart_response.dart';
import 'package:crypto_market_research_app/data/response/crypto/coin_market_response.dart';

class ApiProvider {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.coingecko.com/api/v3',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'x-cg-demo-api-key': 'CG-nAuuSpabyKnvVCD9Me6jqYqx'},
    ),
  );

  String _handleError(Object error) {
    if (error is DioException) {
      if (error.response?.statusCode == 429) {
        return 'API rate limit exceeded. Please try again later.';
      }

      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403) {
        return 'API key is invalid or access is not permitted.';
      }

      return error.response?.data is Map &&
              error.response?.data['error'] != null
          ? error.response?.data['error'].toString() ?? 'Something went wrong'
          : error.message ?? 'Network error occurred';
    }

    return error.toString().replaceAll('Exception: ', '');
  }

  Future<CoinMarketResponse> fetchCoins() async {
    try {
      final response = await _dio.get(
        '/coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'order': 'market_cap_desc',
          'per_page': 100,
          'page': 1,
          'sparkline': false,
          'price_change_percentage': '24h',
        },
      );

      return CoinMarketResponse.fromJson(
        List<dynamic>.from(response.data as List),
      );
    } catch (error) {
      throw Exception(_handleError(error));
    }
  }

  Future<CoinChartResponse> fetchCoinChart({
    required String coinId,
    required int days,
  }) async {
    try {
      final response = await _dio.get(
        '/coins/$coinId/market_chart',
        queryParameters: {'vs_currency': 'usd', 'days': days},
      );

      return CoinChartResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw Exception(_handleError(error));
    }
  }

  Future<GlobalMarketResponse> fetchGlobalMarket() async {
    try {
      final response = await _dio.get('/global');

      return GlobalMarketResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map
            ? (e.response?.data['error']?.toString() ??
                  e.message ??
                  'Failed to fetch global market data')
            : e.message ?? 'Failed to fetch global market data',
      );
    }
  }

  Future<CoinMarketResponse> fetchWatchlistMarketData({
    required List<String> coinIds,
  }) async {
    if (coinIds.isEmpty) {
      return CoinMarketResponse(coins: []);
    }

    try {
      final response = await _dio.get(
        '/coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'ids': coinIds.join(','),
          'order': 'market_cap_desc',
          'per_page': coinIds.length.clamp(1, 250),
          'page': 1,
          'sparkline': false,
          'price_change_percentage': '24h',
        },
      );

      final data = response.data as List<dynamic>;

      return CoinMarketResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map
            ? (e.response?.data['error']?.toString() ??
                  e.message ??
                  'Failed to fetch watchlist')
            : e.message ?? 'Failed to fetch watchlist',
      );
    }
  }
}

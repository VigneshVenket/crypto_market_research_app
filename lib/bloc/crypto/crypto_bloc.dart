import 'package:crypto_market_research_app/repo/crypto_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market_research_app/data/response/crypto/coin_market_response.dart';
import 'package:crypto_market_research_app/data/response/crypto/coin_chart_response.dart';
import 'package:crypto_market_research_app/data/response/crypto/global_market_response.dart';
import 'crypto_event.dart';
import 'crypto_state.dart';

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  final CryptoRepo cryptoRepo;

  CoinMarketResponse? _coinsResponse;
  CoinChartResponse? _chartResponse;
  String? _chartCoinId;
  GlobalMarketResponse? _globalMarketResponse;
  CoinMarketResponse? _watchlistResponse;

  CryptoBloc(this.cryptoRepo) : super(const CryptoInitial()) {
    on<FetchCoins>((event, emit) async {
      emit(_loading('FetchCoins'));

      try {
        final response = await cryptoRepo.fetchCoins();

        if (response.status == 'success') {
          _coinsResponse = response;
          emit(
            CryptoCoinsSuccess(
              response,
              chartResponse: _chartResponse,
              chartCoinId: _chartCoinId,
              globalMarketResponse: _globalMarketResponse,
              watchlistResponse: _watchlistResponse,
            ),
          );
        } else {
          emit(_error('Something went wrong', 'FetchCoins'));
        }
      } catch (e) {
        emit(_error(_clean(e), 'FetchCoins'));
      }
    });

    on<FetchCoinChart>((event, emit) async {
      emit(_loading('FetchCoinChart'));

      try {
        final response = await cryptoRepo.fetchCoinChart(
          coinId: event.coinId,
          days: event.days,
        );

        if (response.status == 'success') {
          _chartResponse = response;
          _chartCoinId = event.coinId;

          emit(
            CryptoChartSuccess(
              response: response,
              coinId: event.coinId,
              coinsResponse: _coinsResponse,
              globalMarketResponse: _globalMarketResponse,
              watchlistResponse: _watchlistResponse,
            ),
          );
        } else {
          emit(_error('Something went wrong', 'FetchCoinChart'));
        }
      } catch (e) {
        emit(_error(_clean(e), 'FetchCoinChart'));
      }
    });

    on<FetchMarketStats>((event, emit) async {
      emit(_loading('FetchMarketStats'));

      try {
        final response = await cryptoRepo.fetchGlobalMarket();

        if (response.status == 'success') {
          _globalMarketResponse = response;

          emit(
            CryptoMarketStatsSuccess(
              response: response,
              coinsResponse: _coinsResponse,
              chartResponse: _chartResponse,
              chartCoinId: _chartCoinId,
              watchlistResponse: _watchlistResponse,
            ),
          );
        } else {
          emit(_error('Something went wrong', 'FetchMarketStats'));
        }
      } catch (e) {
        emit(_error(_clean(e), 'FetchMarketStats'));
      }
    });

    on<FetchWatchlist>((event, emit) async {
      emit(_loading('FetchWatchlist'));

      try {
        final response =
        await cryptoRepo.fetchWatchlistMarketData(
          coinIds: event.coinIds,
        );

        if (response.status == 'success') {
          _watchlistResponse = response;

          emit(
            CryptoWatchlistSuccess(
              response: response,
              coinsResponse: _coinsResponse,
              chartResponse: _chartResponse,
              chartCoinId: _chartCoinId,
              globalMarketResponse: _globalMarketResponse,
            ),
          );
        } else {
          emit(_error('Something went wrong', 'FetchWatchlist'));
        }
      } catch (e) {
        emit(_error(_clean(e), 'FetchWatchlist'));
      }
    });

    on<WatchlistUpdated>((event, emit) {
      emit(
        WatchlistUpdateSuccess(
          coinId: event.coinId,
          isAdded: event.isAdded,
          message: event.isAdded
              ? 'Coin added to your watchlist'
              : 'Coin removed from your watchlist',
          coinsResponse: _coinsResponse,
          chartResponse: _chartResponse,
          chartCoinId: _chartCoinId,
          globalMarketResponse: _globalMarketResponse,
          watchlistResponse: _watchlistResponse,
        ),
      );
    });
  }

  CryptoLoading _loading(String loadingFor) {
    return CryptoLoading(
      loadingFor: loadingFor,
      coinsResponse: _coinsResponse,
      chartResponse: _chartResponse,
      chartCoinId: _chartCoinId,
      globalMarketResponse: _globalMarketResponse,
      watchlistResponse: _watchlistResponse,
    );
  }

  CryptoError _error(String message, String errorFor) {
    return CryptoError(
      message,
      errorFor,
      coinsResponse: _coinsResponse,
      chartResponse: _chartResponse,
      chartCoinId: _chartCoinId,
      globalMarketResponse: _globalMarketResponse,
      watchlistResponse: _watchlistResponse,
    );
  }

  String _clean(Object e) =>
      e.toString().replaceAll('Exception: ', '');
}
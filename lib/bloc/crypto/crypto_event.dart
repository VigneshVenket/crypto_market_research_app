abstract class CryptoEvent {}

class FetchCoins extends CryptoEvent {}

class FetchCoinChart extends CryptoEvent {
  final String coinId;
  final int days;

  FetchCoinChart({
    required this.coinId,
    required this.days,
  });
}

class FetchMarketStats extends CryptoEvent {}

class FetchWatchlist extends CryptoEvent {
  final List<String> coinIds;

  FetchWatchlist({
    required this.coinIds,
  });
}

class WatchlistUpdated extends CryptoEvent {
  final String coinId;
  final bool isAdded;

  WatchlistUpdated({
    required this.coinId,
    required this.isAdded,
  });
}
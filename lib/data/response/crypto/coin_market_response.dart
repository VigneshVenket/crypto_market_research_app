

import '../../../models/coin.dart';

class CoinMarketResponse {
  final List<Coin> coins;
  final String? status;

  CoinMarketResponse({
    required this.coins,
    this.status,
  });

  factory CoinMarketResponse.fromJson(List<dynamic> json) {
    return CoinMarketResponse(
      coins: json
          .whereType<Map>()
          .map(
            (item) => Coin.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
      status: 'success',
    );
  }
}
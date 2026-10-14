
class Coin {
  final String id;
  final String name;
  final String symbol;
  final String emoji;
  final String? image;
  final double price;
  final double change;
  final double marketCap;
  final double volume;
  final double supply;
  final int? marketCapRank;
  final List<double> history;

  const Coin({
    required this.id,
    required this.name,
    required this.symbol,
    this.emoji = '🪙',
    this.image,
    required this.price,
    required this.change,
    required this.marketCap,
    required this.volume,
    required this.supply,
    this.marketCapRank,
    this.history = const [],
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      symbol: (json['symbol']?.toString() ?? '').toUpperCase(),
      image: json['image']?.toString(),
      price: (json['current_price'] as num?)?.toDouble() ?? 0,
      change:
      (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0,
      volume: (json['total_volume'] as num?)?.toDouble() ?? 0,
      supply: (json['circulating_supply'] as num?)?.toDouble() ?? 0,
      marketCapRank: (json['market_cap_rank'] as num?)?.toInt(),
    );
  }

  Coin copyWith({List<double>? history}) {
    return Coin(
      id: id,
      name: name,
      symbol: symbol,
      emoji: emoji,
      image: image,
      price: price,
      change: change,
      marketCap: marketCap,
      volume: volume,
      supply: supply,
      marketCapRank: marketCapRank,
      history: history ?? this.history,
    );
  }
}

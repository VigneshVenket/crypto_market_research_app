class GlobalMarketResponse {
  final double totalMarketCap;
  final double totalVolume;
  final double bitcoinDominance;
  final double marketCapChangePercentage24h;
  final double? volumeChangePercentage24h;
  final String status;

  const GlobalMarketResponse({
    required this.totalMarketCap,
    required this.totalVolume,
    required this.bitcoinDominance,
    required this.marketCapChangePercentage24h,
    this.volumeChangePercentage24h,
    this.status = 'success',
  });

  factory GlobalMarketResponse.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map? ?? {});

    final marketCap = Map<String, dynamic>.from(
      data['total_market_cap'] as Map? ?? {},
    );

    final volume = Map<String, dynamic>.from(
      data['total_volume'] as Map? ?? {},
    );

    final dominance = Map<String, dynamic>.from(
      data['market_cap_percentage'] as Map? ?? {},
    );

    return GlobalMarketResponse(
      totalMarketCap: (marketCap['usd'] as num?)?.toDouble() ?? 0,
      totalVolume: (volume['usd'] as num?)?.toDouble() ?? 0,
      bitcoinDominance: (dominance['btc'] as num?)?.toDouble() ?? 0,
      marketCapChangePercentage24h:
          (data['market_cap_change_percentage_24h_usd'] as num?)?.toDouble() ??
          0,
      volumeChangePercentage24h:
          (data['volume_change_percentage_24h_usd'] as num?)?.toDouble(),
    );
  }
}

class CoinChartResponse {
  final List<double> prices;
  final String? status;

  CoinChartResponse({
    required this.prices,
    this.status,
  });

  factory CoinChartResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    final List<dynamic> priceData =
        json['prices'] as List<dynamic>? ?? [];

    return CoinChartResponse(
      prices: priceData.map<double>((item) {
        return (item[1] as num).toDouble();
      }).toList(),
      status: 'success',
    );
  }
}
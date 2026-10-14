import 'package:crypto_market_research_app/bloc/crypto/crypto_bloc.dart';
import 'package:crypto_market_research_app/bloc/crypto/crypto_event.dart';
import 'package:crypto_market_research_app/bloc/crypto/crypto_state.dart';
import 'package:crypto_market_research_app/models/coin.dart';
import 'package:crypto_market_research_app/utils/app_colors.dart';
import 'package:crypto_market_research_app/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

String _money(double value) {
  if (value >= 1e12) return '\$${(value / 1e12).toStringAsFixed(2)}T';
  if (value >= 1e9) return '\$${(value / 1e9).toStringAsFixed(2)}B';
  if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(2)}M';
  if (value >= 1e3) return '\$${(value / 1e3).toStringAsFixed(2)}K';
  return '\$${value.toStringAsFixed(2)}';
}

String _fullMoney(double value) {
  if (value != 0 && value.abs() < 0.01) {
    return '\$${value.toStringAsFixed(8)}';
  }
  return '\$${value.toStringAsFixed(2)}';
}

String _formatSupply(double value) {
  if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(2)}T';
  if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
  if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
  if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}K';
  return value.toStringAsFixed(2);
}

class CoinDetailsScreen extends StatefulWidget {
  final Coin coin;
  final bool isSaved;
  final VoidCallback onToggle;

  const CoinDetailsScreen({
    super.key,
    required this.coin,
    required this.isSaved,
    required this.onToggle,
  });

  @override
  State<CoinDetailsScreen> createState() => _CoinDetailsScreenState();
}

class _CoinDetailsScreenState extends State<CoinDetailsScreen> {
  String period = '1D';

  @override
  void initState() {
    super.initState();
    _fetchChart();
  }

  @override
  void didUpdateWidget(covariant CoinDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.coin.id != widget.coin.id) {
      _fetchChart();
    }
  }

  int _daysForPeriod(String selectedPeriod) {
    switch (selectedPeriod) {
      case '1H':
      case '1D':
        return 1;
      case '1W':
        return 7;
      case '1M':
        return 30;
      case '1Y':
      case 'ALL':
        return 365;
      default:
        return 1;
    }
  }

  void _fetchChart() {
    context.read<CryptoBloc>().add(
      FetchCoinChart(coinId: widget.coin.id, days: _daysForPeriod(period)),
    );
  }

  void _changePeriod(String selectedPeriod) {
    setState(() => period = selectedPeriod);

    context.read<CryptoBloc>().add(
      FetchCoinChart(
        coinId: widget.coin.id,
        days: _daysForPeriod(selectedPeriod),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coin = widget.coin;
    final positive = coin.change >= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${coin.name} (${coin.symbol.toUpperCase()})'),
        actions: [
          IconButton(
            onPressed: widget.onToggle,
            icon: Icon(
              widget.isSaved ? Iconsax.archive_1 : Iconsax.archive,
              color: AppColors.purple,
            ),
          ),
        ],
      ),
      body: BlocBuilder<CryptoBloc, CryptoState>(
        builder: (context, state) {
          final isLoadingChart =
              state is CryptoLoading && state.loadingFor == 'FetchCoinChart';

          final chartError =
              state is CryptoError && state.errorFor == 'FetchCoinChart';

          final hasCurrentChart =
              state.chartCoinId == coin.id && state.chartResponse != null;

          final chartPrices = hasCurrentChart
              ? state.chartResponse!.prices
              : <double>[];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.purple.withValues(alpha: 0.2),
                  backgroundImage: coin.image!.isNotEmpty
                      ? NetworkImage(coin.image!)
                      : null,
                  child: coin.image!.isEmpty
                      ? Text(coin.emoji, style: const TextStyle(fontSize: 28))
                      : null,
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  coin.name,
                  style: AppStyles.semiBold.copyWith(
                    color: AppColors.muted,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _fullMoney(coin.price),
                  style: AppStyles.semiBold.copyWith(fontSize: 34),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${positive ? '+' : ''}${coin.change.toStringAsFixed(2)}% today',
                  style: AppStyles.semiBold.copyWith(
                    color: positive ? AppColors.green : AppColors.red,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price Performance', style: AppStyles.semiBold),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 190,
                      width: double.infinity,
                      child: isLoadingChart && !hasCurrentChart
                          ? const Center(child: CircularProgressIndicator())
                          : chartPrices.length >= 2
                          ? CustomPaint(
                              painter: PriceChartPainter(
                                values: chartPrices,
                                lineColor: positive
                                    ? AppColors.green
                                    : AppColors.red,
                              ),
                            )
                          : chartError
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Iconsax.warning_2),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: AppStyles.semiBold,
                                  ),
                                  TextButton(
                                    onPressed: _fetchChart,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : const Center(
                              child: Text('No chart data available'),
                            ),
                    ),
                    const SizedBox(height: 18),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['1H', '1D', '1W', '1M', '1Y', 'ALL']
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(item),
                                  selected: period == item,
                                  onSelected: (_) => _changePeriod(item),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Market Information',
                style: AppStyles.bold.copyWith(fontSize: 19),
              ),
              const SizedBox(height: 12),
              InfoCard(label: 'Market Cap', value: _money(coin.marketCap)),
              InfoCard(label: '24h Trading Volume', value: _money(coin.volume)),
              InfoCard(
                label: 'Circulating Supply',
                value:
                    '${_formatSupply(coin.supply)} ${coin.symbol.toUpperCase()}',
              ),
              InfoCard(
                label: 'Market Cap Rank',
                value: coin.marketCapRank! > 0
                    ? '#${coin.marketCapRank}'
                    : 'N/A',
              ),
            ],
          );
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const InfoCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.card)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppStyles.semiBold.copyWith(color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppStyles.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class PriceChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  PriceChartPainter({required this.values, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.muted.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.length < 2) return;

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final safeRange = range == 0 ? 1.0 : range;

    final points = List.generate(values.length, (index) {
      return Offset(
        size.width * index / (values.length - 1),
        size.height -
            ((values[index] - minValue) / safeRange) * (size.height - 12) -
            6,
      );
    });

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
    canvas.drawCircle(points.last, 4, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(covariant PriceChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}

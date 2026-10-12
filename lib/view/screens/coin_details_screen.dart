import 'package:crypto_market_research_app/main.dart';
import 'package:crypto_market_research_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';


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
  Widget build(BuildContext context) {
    final c = widget.coin;
    final positive = c.change >= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${c.name} (${c.symbol})'),
        actions: [
          IconButton(
            onPressed: () {
              widget.onToggle();
              setState(() {});
            },
            icon: Icon(
              widget.isSaved ? Iconsax.archive_1 : Iconsax.archive,
              color: AppColors.purple,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.purple.withValues(alpha: 0.2),
            child: Text(c.emoji,
                style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 18),
          Center(child: Text(c.name,
              style: const TextStyle(color: AppColors.muted, fontSize: 16))),
          const SizedBox(height: 8),
          Center(child: Text(fullMoney(c.price),
              style: const TextStyle(
                  fontSize: 34, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${positive ? '+' : ''}${c.change.toStringAsFixed(2)}% today',
              style: TextStyle(color: positive ? AppColors.green : AppColors.red),
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
                const Text('Price Performance',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: PriceChartPainter(
                      values: c.history,
                      lineColor: positive ? AppColors.green : AppColors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['1H', '1D', '1W', '1M', '1Y', 'ALL']
                      .map((p) => ChoiceChip(
                    label: Text(p),
                    selected: period == p,
                    onSelected: (_) => setState(() => period = p),
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Market Information',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          InfoCard(label: 'Market Cap', value: money(c.marketCap)),
          InfoCard(label: '24h Trading Volume', value: money(c.volume)),
          InfoCard(label: 'Circulating Supply',
              value: '${c.supply}M ${c.symbol}'),
          InfoCard(label: 'Market Cap Rank',
              value: '#${coins.indexOf(c) + 1}'),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String label, value;
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
          Expanded(child: Text(label,
              style: const TextStyle(color: AppColors.muted))),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
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
    final range = (maxValue - minValue).abs();
    final safeRange = range == 0 ? 1.0 : range;

    final points = List.generate(values.length, (i) {
      return Offset(
        size.width * i / (values.length - 1),
        size.height - ((values[i] - minValue) / safeRange) *
            (size.height - 12) - 6,
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
  bool shouldRepaint(covariant PriceChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.lineColor != lineColor;
}
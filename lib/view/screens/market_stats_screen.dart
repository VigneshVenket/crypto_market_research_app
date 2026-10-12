
import 'package:crypto_market_research_app/main.dart';
import 'package:crypto_market_research_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'coin_list_screen.dart';

class MarketStatsScreen extends StatelessWidget {
  final ValueChanged<Coin> onCoinTap;

  const MarketStatsScreen({
    super.key,
    required this.onCoinTap,
  });

  @override
  Widget build(BuildContext context) {
    final gainers = [...coins]
      ..sort((a, b) => b.change.compareTo(a.change));

    final losers = [...coins]
      ..sort((a, b) => a.change.compareTo(b.change));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Market Overview',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'The crypto market at a glance',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 22),

        const StatCard(
          title: 'Total Market Cap',
          value: '\$2.48T',
          change: '+2.31%',
          icon: Iconsax.chart_2,
        ),
        const SizedBox(height: 12),

        const StatCard(
          title: '24h Trading Volume',
          value: '\$86.4B',
          change: '+8.42%',
          icon: Iconsax.chart_1,
        ),
        const SizedBox(height: 12),

        const StatCard(
          title: 'Bitcoin Dominance',
          value: '53.8%',
          change: '+0.24%',
          icon: Iconsax.bitcoin_convert,
        ),
        const SizedBox(height: 26),

        const Text(
          'Top Gainers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        ...gainers.take(3).map(
              (c) => CoinTile(
            coin: c,
            onTap: () => onCoinTap(c),
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Top Losers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        ...losers.take(3).map(
              (c) => CoinTile(
            coin: c,
            onTap: () => onCoinTap(c),
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
            AppColors.purple.withValues(alpha: 0.2),
            child: Icon(
              icon,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Text(
            change,
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

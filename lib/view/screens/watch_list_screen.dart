
import 'package:crypto_market_research_app/main.dart';
import 'package:crypto_market_research_app/utils/app_colors.dart';
import 'package:crypto_market_research_app/view/screens/coin_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class WatchlistScreen extends StatelessWidget {
  final List<Coin> savedCoins;
  final ValueChanged<Coin> onCoinTap;
  final ValueChanged<String> onRemove;

  const WatchlistScreen({
    super.key,
    required this.savedCoins,
    required this.onCoinTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'My Watchlist',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),

        Text(
          '${savedCoins.length} coins saved',
          style: const TextStyle(
            color: AppColors.muted,
          ),
        ),

        const SizedBox(height: 22),

        if (savedCoins.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(
                  Iconsax.bookmark,
                  size: 48,
                  color: AppColors.muted,
                ),
                SizedBox(height: 12),
                Text(
                  'Your watchlist is empty',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Save coins to track their prices here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),

        ...savedCoins.map(
              (c) => CoinTile(
            coin: c,
            onTap: () => onCoinTap(c),
            trailing: IconButton(
              tooltip: 'Remove from watchlist',
              icon: const Icon(
                Iconsax.trash,
                color: AppColors.muted,
              ),
              onPressed: () => onRemove(c.id),
            ),
          ),
        ),
      ],
    );
  }
}

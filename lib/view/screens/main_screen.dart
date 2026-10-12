
import 'package:crypto_market_research_app/main.dart';
import 'package:crypto_market_research_app/utils/app_colors.dart';
import 'package:crypto_market_research_app/utils/app_styles.dart';
import 'package:crypto_market_research_app/view/screens/watch_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'coin_details_screen.dart';
import 'coin_list_screen.dart';
import 'market_stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int tab = 0;

  final Set<String> watchlist = {'bitcoin', 'ethereum'};

  void toggle(String id) {
    setState(() {
      if (!watchlist.add(id)) {
        watchlist.remove(id);
      }
    });
  }

  void openCoin(Coin coin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoinDetailsScreen(
          coin: coin,
          isSaved: watchlist.contains(coin.id),
          onToggle: () => toggle(coin.id),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      CoinListScreen(onCoinTap: openCoin),
      MarketStatsScreen(onCoinTap: openCoin),
      WatchlistScreen(
        savedCoins:
        coins.where((c) => watchlist.contains(c.id)).toList(),
        onCoinTap: openCoin,
        onRemove: toggle,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title:  Row(
          children: [
            Icon(
              Icons.currency_bitcoin,
              color: AppColors.purple,
              size: 30,
            ),
            SizedBox(width: 8),
            Text(
              'CoinScope',
              style:AppStyles.bold,
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Iconsax.notification,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: tab,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.purple.withValues(alpha: 0.22),
        selectedIndex: tab,
        onDestinationSelected: (i) {
          setState(() => tab = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Iconsax.coin),
            label: 'Coins',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.chart_2),
            label: 'Markets',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.bookmark),
            label: 'Watchlist',

          ),
        ],
      ),
    );
  }
}

import 'package:crypto_market_research_app/bloc/crypto/crypto_bloc.dart';
import 'package:crypto_market_research_app/bloc/crypto/crypto_event.dart';
import 'package:crypto_market_research_app/bloc/crypto/crypto_state.dart';
import 'package:crypto_market_research_app/models/coin.dart';
import 'package:crypto_market_research_app/utils/app_colors.dart';
import 'package:crypto_market_research_app/utils/app_images.dart';
import 'package:crypto_market_research_app/utils/app_styles.dart';
import 'package:crypto_market_research_app/view/screens/watch_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    bool isAdded = false;

    setState(() {
      if (watchlist.contains(id)) {
        watchlist.remove(id);
        isAdded = false;
      } else {
        watchlist.add(id);
        isAdded = true;
      }
    });

    context.read<CryptoBloc>().add(
      WatchlistUpdated(coinId: id, isAdded: isAdded),
    );

    context.read<CryptoBloc>().add(FetchWatchlist(coinIds: watchlist.toList()));
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
    return BlocListener<CryptoBloc, CryptoState>(
      listener: (context, state) {
        if (state is WatchlistUpdateSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: Colors.white,
                content: Text(state.message,style: AppStyles.semiBold.copyWith(color: AppColors.bg),),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(AppImages.appLogo),
              ),
              SizedBox(
                width: 170,
                height: 50,
                child: Image.asset(AppImages.appName),
              ),
            ],
          ),
        ),
        body: BlocBuilder<CryptoBloc, CryptoState>(
          builder: (context, state) {
            final allCoins = state.coinsResponse?.coins ?? <Coin>[];

            final pages = [
              CoinListScreen(onCoinTap: openCoin),
              MarketStatsScreen(onCoinTap: openCoin),
              WatchlistScreen(
                savedCoins: allCoins
                    .where((coin) => watchlist.contains(coin.id))
                    .toList(),
                onCoinTap: openCoin,
                onRemove: toggle,
              ),
            ];

            return IndexedStack(index: tab, children: pages);
          },
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
              states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return AppStyles.semiBold.copyWith(
                  fontSize: 13,
                  color: AppColors.purple,
                );
              }

              return AppStyles.semiBold.copyWith(
                fontSize: 12,
                color: AppColors.muted,
              );
            }),
          ),
          child: NavigationBar(
            backgroundColor: AppColors.card,
            indicatorColor: AppColors.purple.withValues(alpha: 0.22),
            selectedIndex: tab,
            onDestinationSelected: (index) {
              setState(() => tab = index);
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(icon: Icon(Iconsax.coin), label: 'Coins'),
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
        ),
      ),
    );
  }
}

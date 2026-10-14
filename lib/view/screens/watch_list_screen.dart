import 'package:crypto_market_research_app/bloc/crypto/crypto_bloc.dart';
import 'package:crypto_market_research_app/bloc/crypto/crypto_event.dart';
import 'package:crypto_market_research_app/bloc/crypto/crypto_state.dart';
import 'package:crypto_market_research_app/models/coin.dart';
import 'package:crypto_market_research_app/utils/app_colors.dart';
import 'package:crypto_market_research_app/utils/app_styles.dart';
import 'package:crypto_market_research_app/view/screens/coin_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class WatchlistScreen extends StatefulWidget {
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
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    _fetchWatchlist();
  }

  @override
  void didUpdateWidget(covariant WatchlistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldIds = oldWidget.savedCoins.map((coin) => coin.id).join(',');
    final newIds = widget.savedCoins.map((coin) => coin.id).join(',');

    if (oldIds != newIds) {
      _fetchWatchlist();
    }
  }

  void _fetchWatchlist() {
    context.read<CryptoBloc>().add(
      FetchWatchlist(
        coinIds: widget.savedCoins.map((coin) => coin.id).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CryptoBloc, CryptoState>(
      builder: (context, state) {
        final savedIds =
        widget.savedCoins.map((coin) => coin.id).toList();

        final marketCoins = state.watchlistResponse?.coins ?? [];

        // Keep the user's saved order, even if the API returns a
        // different order based on market capitalization.
        final marketById = {
          for (final coin in marketCoins) coin.id: coin,
        };

        final displayedCoins = savedIds.map((id) {
          return marketById[id] ??
              widget.savedCoins.firstWhere((coin) => coin.id == id);
        }).toList();

        final isLoading = state is CryptoLoading &&
            state.loadingFor == 'FetchWatchlist';

        final hasError = state is CryptoError &&
            state.errorFor == 'FetchWatchlist';

        return RefreshIndicator(
          onRefresh: () async {
            _fetchWatchlist();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'My Watchlist',
                style: AppStyles.semiBold.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.savedCoins.length} coins saved',
                style: AppStyles.semiBold.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 22),

              if (isLoading && displayedCoins.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (hasError)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Could not refresh watchlist prices: '
                            '${(state as CryptoError).message}',
                        style: AppStyles.semiBold,
                      ),
                      TextButton.icon(
                        onPressed: _fetchWatchlist,
                        icon: const Icon(Iconsax.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),

              if (displayedCoins.isEmpty && !isLoading)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Iconsax.bookmark,
                        size: 48,
                        color: AppColors.muted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your watchlist is empty',
                        style: AppStyles.bold,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Save coins to track their prices here.',
                        textAlign: TextAlign.center,
                        style: AppStyles.semiBold.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),

              ...displayedCoins.map(
                    (coin) => CoinTile(
                  coin: coin,
                  onTap: () => widget.onCoinTap(coin),
                  trailing: IconButton(
                    tooltip: 'Remove from watchlist',
                    icon: const Icon(
                      Iconsax.trash,
                      color: AppColors.muted,
                    ),
                    onPressed: () => widget.onRemove(coin.id),
                  ),
                ),
              ),

              if (isLoading && displayedCoins.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
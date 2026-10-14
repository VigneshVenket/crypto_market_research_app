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

String _formatMarketValue(double value) {
  if (value >= 1e12) {
    return '\$${(value / 1e12).toStringAsFixed(2)}T';
  }
  if (value >= 1e9) {
    return '\$${(value / 1e9).toStringAsFixed(2)}B';
  }
  if (value >= 1e6) {
    return '\$${(value / 1e6).toStringAsFixed(2)}M';
  }
  if (value >= 1e3) {
    return '\$${(value / 1e3).toStringAsFixed(2)}K';
  }
  return '\$${value.toStringAsFixed(2)}';
}

String _formatChange(double value) {
  return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%';
}

class MarketStatsScreen extends StatefulWidget {
  final ValueChanged<Coin> onCoinTap;

  const MarketStatsScreen({
    super.key,
    required this.onCoinTap,
  });

  @override
  State<MarketStatsScreen> createState() =>
      _MarketStatsScreenState();
}

class _MarketStatsScreenState extends State<MarketStatsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    context.read<CryptoBloc>().add(FetchMarketStats());
    context.read<CryptoBloc>().add(FetchCoins());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CryptoBloc, CryptoState>(
      builder: (context, state) {
        final global = state.globalMarketResponse;
        final coins = state.coinsResponse?.coins ?? [];

        final isLoading = state is CryptoLoading &&
            (state.loadingFor == 'FetchMarketStats' ||
                state.loadingFor == 'FetchCoins');

        final marketError = state is CryptoError &&
            state.errorFor == 'FetchMarketStats';

        final coinsError = state is CryptoError &&
            state.errorFor == 'FetchCoins';

        final gainers = [...coins]
          ..sort((a, b) => b.change.compareTo(a.change));

        final losers = [...coins]
          ..sort((a, b) => a.change.compareTo(b.change));

        return RefreshIndicator(
          onRefresh: () async {
            _fetchData();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Market Overview',
                style: AppStyles.semiBold.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 6),
              Text(
                'The crypto market at a glance',
                style: AppStyles.semiBold.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 22),

              if (isLoading && global == null && coins.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (marketError && global == null)
                _ErrorPanel(
                  message: (state as CryptoError).message,
                  onRetry: () {
                    context.read<CryptoBloc>().add(
                      FetchMarketStats(),
                    );
                  },
                ),

              if (global != null) ...[
                StatCard(
                  title: 'Total Market Cap',
                  value: _formatMarketValue(global.totalMarketCap),
                  change: _formatChange(
                    global.marketCapChangePercentage24h,
                  ),
                  icon: Iconsax.chart_2,
                  changeValue: global.marketCapChangePercentage24h,
                ),
                const SizedBox(height: 12),
                StatCard(
                  title: '24h Trading Volume',
                  value: _formatMarketValue(global.totalVolume),
                  change: global.volumeChangePercentage24h == null
                      ? '24h volume'
                      : _formatChange(
                    global.volumeChangePercentage24h!,
                  ),
                  icon: Iconsax.chart_1,
                  changeValue: global.volumeChangePercentage24h,
                ),
                const SizedBox(height: 12),
                StatCard(
                  title: 'Bitcoin Dominance',
                  value:
                  '${global.bitcoinDominance.toStringAsFixed(2)}%',
                  change: 'Market share',
                  icon: Iconsax.bitcoin_convert,
                ),
              ],

              if (coinsError && coins.isEmpty)
                _ErrorPanel(
                  message: state.message,
                  onRetry: () {
                    context.read<CryptoBloc>().add(FetchCoins());
                  },
                ),

              const SizedBox(height: 26),
              Text(
                'Top Gainers',
                style: AppStyles.semiBold.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (coins.isNotEmpty)
                ...gainers.take(3).map(
                      (coin) => CoinTile(
                    coin: coin,
                    onTap: () => widget.onCoinTap(coin),
                  ),
                )
              else if (!isLoading && !coinsError)
                const Text('No market data available'),

              const SizedBox(height: 18),
              Text(
                'Top Losers',
                style: AppStyles.semiBold.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 12),

              if (coins.isNotEmpty)
                ...losers.take(3).map(
                      (coin) => CoinTile(
                    coin: coin,
                    onTap: () => widget.onCoinTap(coin),
                  ),
                ),

              if (isLoading && (global != null || coins.isNotEmpty))
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
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

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Iconsax.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final double? changeValue;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    this.changeValue,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = changeValue == null
        ? AppColors.muted
        : changeValue! >= 0
        ? AppColors.green
        : AppColors.red;

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
            child: Icon(icon, color: AppColors.purple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.semiBold.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppStyles.bold.copyWith(fontSize: 23),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              change,
              textAlign: TextAlign.end,
              style: AppStyles.semiBold.copyWith(
                color: changeColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
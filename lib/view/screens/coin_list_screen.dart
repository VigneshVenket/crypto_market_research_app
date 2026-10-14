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

class CoinListScreen extends StatefulWidget {
  final ValueChanged<Coin> onCoinTap;

  const CoinListScreen({super.key, required this.onCoinTap});

  @override
  State<CoinListScreen> createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  String query = '';
  String sort = 'Market Cap';
  bool gainersOnly = false;

  @override
  void initState() {
    super.initState();
    context.read<CryptoBloc>().add(FetchCoins());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CryptoBloc, CryptoState>(
      builder: (context, state) {
        final coins = state.coinsResponse?.coins ?? [];

        if (coins.isEmpty &&
            state is CryptoLoading &&
            state.loadingFor == 'FetchCoins') {
          return const Center(child: CircularProgressIndicator());
        }

        if (coins.isEmpty &&
            state is CryptoError &&
            state.errorFor == 'FetchCoins') {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.warning_2, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: AppStyles.semiBold,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<CryptoBloc>().add(FetchCoins()),
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final filtered = coins.where((coin) {
          final matches =
              coin.name.toLowerCase().contains(query.toLowerCase()) ||
              coin.symbol.toLowerCase().contains(query.toLowerCase());

          return matches && (!gainersOnly || coin.change > 0);
        }).toList();

        if (sort == 'Price') {
          filtered.sort((a, b) => b.price.compareTo(a.price));
        } else if (sort == '24h Change') {
          filtered.sort((a, b) => b.change.compareTo(a.change));
        } else {
          filtered.sort((a, b) => b.marketCap.compareTo(a.marketCap));
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<CryptoBloc>().add(FetchCoins());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Crypto Market',
                style: AppStyles.bold.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 6),
              Text(
                'Explore cryptocurrency prices',
                style: AppStyles.semiBold.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: InputDecoration(
                  hintText: 'Search coins or symbols',
                  hintStyle: AppStyles.semiBold,
                  prefixIcon: const Icon(Iconsax.search_normal),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Sort by',
                    style: AppStyles.semiBold.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: sort,
                    underline: const SizedBox(),
                    style: AppStyles.semiBold,
                    items: ['Market Cap', 'Price', '24h Change']
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => sort = value);
                      }
                    },
                  ),
                  const Spacer(),
                  FilterChip(
                    label: Text('Gainers', style: AppStyles.semiBold),
                    selected: gainersOnly,
                    onSelected: (value) {
                      setState(() => gainersOnly = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('ASSET', style: AppStyles.semiBold),
                  const Spacer(),
                  Text(
                    'PRICE / 24H',
                    style: AppStyles.semiBold.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (state is CryptoError && state.errorFor == 'FetchCoins')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Could not refresh prices: ${state.message}',
                    style: TextStyle(color: AppColors.red),
                  ),
                ),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text('No coins found', style: AppStyles.semiBold),
                  ),
                ),
              ...filtered.map(
                (coin) =>
                    CoinTile(coin: coin, onTap: () => widget.onCoinTap(coin)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CoinTile extends StatelessWidget {
  final Coin coin;
  final VoidCallback onTap;
  final Widget? trailing;

  const CoinTile({
    super.key,
    required this.coin,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final positive = coin.change >= 0;
    final color = positive ? AppColors.green : AppColors.red;

    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.purple.withValues(alpha: 0.18),
          backgroundImage: coin.image!.isNotEmpty
              ? NetworkImage(coin.image!)
              : null,
          child: coin.image!.isEmpty
              ? Text(
                  coin.emoji,
                  style: AppStyles.semiBold.copyWith(color: Colors.white),
                )
              : null,
        ),
        title: Text(coin.name, style: AppStyles.semiBold),
        subtitle: Text(
          coin.symbol.toUpperCase(),
          style: AppStyles.semiBold.copyWith(color: AppColors.muted),
        ),
        trailing: SizedBox(
          width: 132,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(coin.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.semiBold,
                    ),
                    Text(
                      '${positive ? '+' : ''}${coin.change.toStringAsFixed(2)}%',
                      style: AppStyles.semiBold.copyWith(
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 6), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

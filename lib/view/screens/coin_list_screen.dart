import 'package:crypto_market_research_app/main.dart';
import 'package:crypto_market_research_app/utils/app_colors.dart';
import 'package:crypto_market_research_app/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';


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
  Widget build(BuildContext context) {
    var filtered = coins.where((c) {
      final matches = c.name.toLowerCase().contains(query.toLowerCase()) ||
          c.symbol.toLowerCase().contains(query.toLowerCase());
      return matches && (!gainersOnly || c.change > 0);
    }).toList();

    if (sort == 'Price') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (sort == '24h Change') {
      filtered.sort((a, b) => b.change.compareTo(a.change));
    } else {
      filtered.sort((a, b) => b.marketCap.compareTo(a.marketCap));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
         Text('Crypto Market',
            style: AppStyles.bold.copyWith(fontSize: 26)),
        const SizedBox(height: 6),
         Text('Explore cryptocurrency prices',
            style: AppStyles.semiBold.copyWith(color: AppColors.muted)),
        const SizedBox(height: 20),
        TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: InputDecoration(
            hintText: 'Search coins or symbols',
            hintStyle: AppStyles.semiBold,
            prefixIcon: const Icon(Iconsax.search_normal),
            filled: true,
            fillColor:AppColors. card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
             Text('Sort by',
                style: AppStyles.semiBold.copyWith(color: AppColors.muted)),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: sort,
              underline: const SizedBox(),
              style: AppStyles.semiBold,
              items: ['Market Cap', 'Price', '24h Change']
                  .map((s) => DropdownMenuItem(
                  value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => sort = v!),
            ),
            const Spacer(),
            FilterChip(
              label:  Text('Gainers',style: AppStyles.semiBold,),
              selected: gainersOnly,
              onSelected: (v) => setState(() => gainersOnly = v),
            ),
          ],
        ),
        const SizedBox(height: 8),
         Row(
          children: [
            Text('ASSET',style: AppStyles.semiBold),
            Spacer(),
            Text('PRICE / 24H', style: AppStyles.semiBold.copyWith(color: AppColors.muted)),
          ],
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
           Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No coins found',style: AppStyles.semiBold)),
          ),
        ...filtered.map((c) => CoinTile(
          coin: c,
          onTap: () => widget.onCoinTap(c),
        )),
      ],
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 6),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.purple.withValues(alpha: 0.18),
          child: Text(coin.emoji,
              style: AppStyles.semiBold.copyWith(
                  color: Colors.white,)),
        ),
        title: Text(coin.name,
            style: AppStyles.semiBold),
        subtitle: Text(coin.symbol,
            style: AppStyles.semiBold.copyWith(color: AppColors.muted)),
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
                    Text(money(coin.price),
                        maxLines: 1,
                        style: AppStyles.semiBold
                        ),
                    Text(
                      '${positive ? '+' : ''}${coin.change.toStringAsFixed(2)}%',
                      style: AppStyles.semiBold.copyWith(color: color, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
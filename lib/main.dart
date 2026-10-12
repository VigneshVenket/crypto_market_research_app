import 'package:crypto_market_research_app/utils/app_colors.dart';
import 'package:crypto_market_research_app/view/screens/main_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CryptoApp());

class Coin {
  final String id, name, symbol, emoji;
  final double price, change, marketCap, volume, supply;
  final List<double> history;

  const Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.emoji,
    required this.price,
    required this.change,
    required this.marketCap,
    required this.volume,
    required this.supply,
    required this.history,
  });
}

final coins = <Coin>[
  Coin(
    id: 'bitcoin',
    name: 'Bitcoin',
    symbol: 'BTC',
    emoji: '₿',
    price: 67420.50,
    change: 2.45,
    marketCap: 1330000000000,
    volume: 28500000000,
    supply: 19.8,
    history: [2, 3, 2.5, 4, 3.6, 5, 4.5, 7, 6, 8],
  ),
  Coin(
    id: 'ethereum',
    name: 'Ethereum',
    symbol: 'ETH',
    emoji: '◆',
    price: 3520.80,
    change: 1.82,
    marketCap: 423000000000,
    volume: 14200000000,
    supply: 120.1,
    history: [3, 2, 4, 3, 5, 4, 6, 5, 7, 8],
  ),
  Coin(
    id: 'solana',
    name: 'Solana',
    symbol: 'SOL',
    emoji: '◎',
    price: 182.35,
    change: -1.25,
    marketCap: 81000000000,
    volume: 3200000000,
    supply: 445.2,
    history: [8, 7, 8, 5, 6, 4, 5, 3, 4, 2],
  ),
  Coin(
    id: 'binancecoin',
    name: 'BNB',
    symbol: 'BNB',
    emoji: '◆',
    price: 598.40,
    change: 3.12,
    marketCap: 88000000000,
    volume: 1800000000,
    supply: 147.5,
    history: [2, 3, 3, 5, 4, 6, 5, 7, 8, 9],
  ),
  Coin(
    id: 'ripple',
    name: 'XRP',
    symbol: 'XRP',
    emoji: '✕',
    price: 0.62,
    change: -0.85,
    marketCap: 34000000000,
    volume: 950000000,
    supply: 55.2,
    history: [8, 7, 8, 6, 7, 5, 6, 4, 5, 4],
  ),
  Coin(
    id: 'cardano',
    name: 'Cardano',
    symbol: 'ADA',
    emoji: '₳',
    price: 0.45,
    change: 0.95,
    marketCap: 16000000000,
    volume: 380000000,
    supply: 35.6,
    history: [2, 4, 3, 4, 5, 4, 6, 5, 6, 7],
  ),
];

String money(double n) {
  if (n >= 1e12) return '\$${(n / 1e12).toStringAsFixed(2)}T';
  if (n >= 1e9) return '\$${(n / 1e9).toStringAsFixed(2)}B';
  if (n >= 1e6) return '\$${(n / 1e6).toStringAsFixed(2)}M';
  if (n >= 1) return '\$${n.toStringAsFixed(2)}';
  return '\$${n.toStringAsFixed(4)}';
}

String fullMoney(double n) =>
    '\$${n.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';

class CryptoApp extends StatelessWidget {
  const CryptoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Research',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.purple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

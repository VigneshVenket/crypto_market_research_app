import 'package:crypto_market_research_app/bloc/crypto/crypto_bloc.dart';
import 'package:crypto_market_research_app/repo/crypto_repo.dart';
import 'package:crypto_market_research_app/utils/app_colors.dart';
import 'package:crypto_market_research_app/view/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => CryptoBloc(CryptoRepo()),
      child: const CryptoApp(),
    ),
  );
}

String money(double n) {
  if (n >= 1e12) return '\$${(n / 1e12).toStringAsFixed(2)}T';
  if (n >= 1e9) return '\$${(n / 1e9).toStringAsFixed(2)}B';
  if (n >= 1e6) return '\$${(n / 1e6).toStringAsFixed(2)}M';
  if (n >= 1) return '\$${n.toStringAsFixed(2)}';
  return '\$${n.toStringAsFixed(4)}';
}

String fullMoney(double n) {
  final parts = n.toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '\$$whole.${parts[1]}';
}

class CryptoApp extends StatelessWidget {
  const CryptoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

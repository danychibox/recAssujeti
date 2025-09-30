import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_boutique_screen.dart';
import 'screens/list_boutique_screen.dart';
import 'screens/stats_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recensement Boutiques - Beni',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add': (context) => const AddBoutiqueScreen(),
        '/list': (context) => const ListBoutiqueScreen(),
        '/stats': (context) => const StatsScreen(),
      },
    );
  }
}
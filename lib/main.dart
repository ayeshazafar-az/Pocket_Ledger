import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const PocketLedgerApp());
}

class PocketLedgerApp extends StatelessWidget {
  const PocketLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketLedger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/add': (context) => const AddExpenseScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

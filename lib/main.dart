import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/settings_screen.dart';
import 'services/storage_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isDark = await StorageService().getThemeMode();
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  runApp(const PocketLedgerApp());
}

class PocketLedgerApp extends StatelessWidget {
  const PocketLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, child) {
        return MaterialApp(
          title: 'PocketLedger',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: const Color(0xFF2563EB),
              primary: const Color(0xFF2563EB),
              secondary: const Color(0xFF059669),
              surface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: Color(0xFF0F172A)),
              titleTextStyle: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF3B82F6),
              primary: const Color(0xFF3B82F6),
              secondary: const Color(0xFF10B981),
              surface: const Color(0xFF1E293B),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const DashboardScreen(),
            '/add': (context) => const AddExpenseScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

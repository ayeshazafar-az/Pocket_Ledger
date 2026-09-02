import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/settings_screen.dart';
import 'services/storage_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  final isDark = await storage.getThemeMode();
  final isSetup = await storage.isProfileSetup();
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  runApp(PocketLedgerApp(isSetup: isSetup));
}

class PocketLedgerApp extends StatelessWidget {
  final bool isSetup;
  const PocketLedgerApp({super.key, required this.isSetup});

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
            scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: const Color(0xFF6C63FF),
              primary: const Color(0xFF6C63FF),
              secondary: const Color(0xFF00E5FF),
              surface: Colors.white,
            ),
            textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'Montserrat', // Will fallback cleanly to sans-serif
              bodyColor: const Color(0xFF1E1E2C),
              displayColor: const Color(0xFF1E1E2C),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: Color(0xFF1E1E2C)),
              titleTextStyle: TextStyle(
                color: Color(0xFF1E1E2C),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF0A0E17),
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF6C63FF),
              primary: const Color(0xFF8B85FF),
              secondary: const Color(0xFF00E5FF),
              surface: const Color(0xFF151A25),
            ),
            textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'Montserrat',
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          initialRoute: isSetup ? '/dashboard' : '/welcome',
          routes: {
            '/welcome': (context) => const WelcomeScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/add': (context) => const AddExpenseScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

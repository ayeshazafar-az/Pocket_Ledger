import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class StorageService {
  static const String _keyExpenses = 'expenses_list';
  static const String _keyUserName = 'user_name';
  static const String _keyInitialBalance = 'initial_balance';
  static const String _keyCurrency = 'currency_symbol';
  static const String _keyEmail = 'auth_email';
  static const String _keyPassword = 'auth_password';
  static const String _keyIsLoggedIn = 'is_logged_in';

  Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? expensesJson = prefs.getString(_keyExpenses);
    if (expensesJson == null) return [];
    final List<dynamic> decoded = jsonDecode(expensesJson);
    return decoded
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await prefs.setString(_keyExpenses, encoded);
  }

  Future<void> addExpense(Expense expense) async {
    final expenses = await getExpenses();
    expenses.insert(0, expense);
    await saveExpenses(expenses);
  }

  Future<void> deleteExpense(String id) async {
    final expenses = await getExpenses();
    expenses.removeWhere((e) => e.id == id);
    await saveExpenses(expenses);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_dark_mode') ?? false;
  }

  Future<void> setThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }

  Future<bool> hasAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) != null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_keyEmail) == email &&
        prefs.getString(_keyPassword) == password) {
      await setLoggedIn(true);
      return true;
    }
    return false;
  }

  Future<void> registerAndSetup(
    String email,
    String password,
    String name,
    double balance,
    String currency,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setString(_keyUserName, name);
    await prefs.setDouble(_keyInitialBalance, balance);
    await prefs.setString(_keyCurrency, currency);
    await setLoggedIn(true);
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyUserName) ?? 'User',
      'initialBalance': prefs.getDouble(_keyInitialBalance) ?? 0.0,
      'currency': prefs.getString(_keyCurrency) ?? '\$',
    };
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class StorageService {
  static const String _keyExpenses = 'expenses_list';

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
    expenses.insert(0, expense); // Newest first
    await saveExpenses(expenses);
  }

  Future<void> deleteExpense(String id) async {
    final expenses = await getExpenses();
    expenses.removeWhere((e) => e.id == id);
    await saveExpenses(expenses);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyExpenses);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? isDark = prefs.getBool('is_dark_mode');
    return isDark ?? false;
  }

  Future<void> setThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }
}

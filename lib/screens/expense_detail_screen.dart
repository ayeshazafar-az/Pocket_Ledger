import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense? expense;

  const ExpenseDetailScreen({super.key, this.expense});

  @override
  Widget build(BuildContext context) {
    if (expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No expense provided')),
      );
    }

    final e = expense!;
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withAlpha(20)
                          : Colors.black.withAlpha(10),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withAlpha(20),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        e.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<Map<String, dynamic>>(
                        future: StorageService().getUserProfile(),
                        builder: (context, snapshot) {
                          final currency = snapshot.data?['currency'] ?? '\$';
                          return Text(
                            '-$currency${e.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')} • ${e.category}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutQuad,
                ),
            const Spacer(),
            Container(
                  width: double.infinity,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF3B30), Color(0xFFD32F2F)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3B30).withAlpha(80),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      await StorageService().deleteExpense(e.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 24,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Delete Transaction',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }
}

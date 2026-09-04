import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _isLoading = true;
  List<String> _insights = [];
  String _currency = '\$';

  @override
  void initState() {
    super.initState();
    _generateInsights();
  }

  Future<void> _generateInsights() async {
    final storage = StorageService();
    final expenses = await storage.getExpenses();
    final budget = await storage.getMonthlyBudget();
    final profile = await storage.getUserProfile();
    _currency = profile['currency'] as String;

    final insights = <String>[];

    if (expenses.isEmpty) {
      insights.add(
        'Welcome! Start adding expenses to generate AI-driven financial insights.',
      );
    } else {
      // Determine Highest Category
      final categoryMap = <String, double>{};
      double totalSpent = 0;
      for (var e in expenses) {
        categoryMap[e.category] = (categoryMap[e.category] ?? 0) + e.amount;
        totalSpent += e.amount;
      }
      String highestCat = categoryMap.keys.first;
      for (var k in categoryMap.keys) {
        if (categoryMap[k]! > categoryMap[highestCat]!) highestCat = k;
      }

      if (budget > 0) {
        final ratio = totalSpent / budget;
        if (ratio >= 0.9) {
          insights.add(
            '⚠️ Critical: You are utilizing ${(ratio * 100).toStringAsFixed(1)}% of your monthly budget. Cease non-essential spending immediately.',
          );
        } else if (ratio >= 0.5) {
          insights.add(
            'Notice: You have consumed half of your budget. Your highest driver is $highestCat ($_currency${categoryMap[highestCat]!.toStringAsFixed(0)}).',
          );
        } else {
          insights.add(
            'Excellent! You are well within your monthly budget constraints. Great financial discipline.',
          );
        }
      } else {
        insights.add(
          'Insight: Your primary capital sink is $highestCat, comprising ${((categoryMap[highestCat]! / totalSpent) * 100).toStringAsFixed(1)}% of your total expenditure.',
        );
      }

      // Velocity Insight (Last 7 days)
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentExpenses = expenses
          .where((e) => e.date.isAfter(weekAgo))
          .toList();
      final recentTotal = recentExpenses.fold(0.0, (s, e) => s + e.amount);
      if (recentTotal > 0 && budget > 0) {
        final projected = recentTotal * 4.28; // 30 days roughly
        if (projected > budget) {
          insights.add(
            'Velocity Warning: Based on your last 7 days of spending ($_currency${recentTotal.toStringAsFixed(0)}), you are projected to exceed your monthly allowance by $_currency${(projected - budget).toStringAsFixed(0)}.',
          );
        } else {
          insights.add(
            'Stable Velocity: Your recent 7-day spending pattern ($_currency${recentTotal.toStringAsFixed(0)}) maps perfectly to long-term wealth stability.',
          );
        }
      }
    }

    setState(() {
      _insights = insights;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Financial Insights'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _insights.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child:
                          Icon(
                                Icons.auto_awesome,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary,
                              )
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .shimmer(duration: 2.seconds, color: Colors.white)
                              .scaleXY(
                                begin: 0.9,
                                end: 1.0,
                                duration: 1.seconds,
                                curve: Curves.easeInOutSine,
                              )
                              .then()
                              .scaleXY(
                                begin: 1.0,
                                end: 0.9,
                                duration: 1.seconds,
                                curve: Curves.easeInOutSine,
                              ),
                    ),
                  );
                }
                final insight = _insights[index - 1];
                final isWarning =
                    insight.contains('Critical') || insight.contains('Warning');

                return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isWarning
                              ? [
                                  Colors.red.shade900.withAlpha(200),
                                  Colors.red.shade800.withAlpha(200),
                                ]
                              : [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: isWarning
                                ? Colors.red.withAlpha(50)
                                : Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(50),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isWarning
                                ? Icons.warning_amber_rounded
                                : Icons.insights_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              insight,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .slideX(
                      begin: 1.0,
                      end: 0,
                      delay: (index * 100).ms,
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn();
              },
            ),
    );
  }
}

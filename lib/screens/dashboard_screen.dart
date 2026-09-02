import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import 'expense_detail_screen.dart';

enum SortOption { latest, highest, lowest }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storageService = StorageService();
  List<Expense> _expenses = [];
  bool _isLoading = true;
  SortOption _currentSort = SortOption.latest;
  String _userName = 'User';
  double _initialBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    final expenses = await _storageService.getExpenses();

    if (_currentSort == SortOption.latest) {
      expenses.sort((a, b) => b.date.compareTo(a.date));
    } else if (_currentSort == SortOption.highest) {
      expenses.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_currentSort == SortOption.lowest) {
      expenses.sort((a, b) => a.amount.compareTo(b.amount));
    }

    final profile = await _storageService.getUserProfile();

    setState(() {
      _expenses = expenses;
      _userName = profile['name'] as String;
      _initialBalance = profile['initialBalance'] as double;
      _isLoading = false;
    });
  }

  double get _totalSpent =>
      _expenses.fold(0.0, (sum, item) => sum + item.amount);

  Map<String, double> get _categoryTotals {
    final totals = <String, double>{};
    for (var e in _expenses) {
      totals[e.category] = (totals[e.category] ?? 0.0) + e.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $_userName', style: TextStyle(letterSpacing: -0.5)),
        centerTitle: true,
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.tune),
            onSelected: (option) {
              setState(() => _currentSort = option);
              _loadExpenses();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.latest,
                child: Text('Sort by Latest'),
              ),
              const PopupMenuItem(
                value: SortOption.highest,
                child: Text('Sort by Highest'),
              ),
              const PopupMenuItem(
                value: SortOption.lowest,
                child: Text('Sort by Lowest'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              _loadExpenses();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildSummaryCard()),
                SliverToBoxAdapter(child: _buildAnalyticsSection()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                if (_expenses.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState())
                else
                  _buildExpensesList(),
              ],
            ),
      floatingActionButton:
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withAlpha(100),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              onPressed: () async {
                await Navigator.pushNamed(context, '/add');
                _loadExpenses();
              },
              child: const Icon(Icons.add, size: 32),
            ),
          ).animate().scale(
            delay: 500.ms,
            duration: 500.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withRed(150),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withAlpha(100),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Decorative background circles for premium card feel
                Positioned(
                  right: -50,
                  top: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(20),
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: -40,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL BALANCE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                            ),
                          ),
                          Icon(
                            Icons.contactless_outlined,
                            color: Colors.white.withAlpha(150),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '\$${_totalSpent.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '**** 4921',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack)
        .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.white24);
  }

  Widget _buildAnalyticsSection() {
    if (_expenses.isEmpty) return const SizedBox();

    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];
    int colorIndex = 0;
    final pieSections = _categoryTotals.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        value: entry.value,
        color: color,
        title: entry.key,
        radius: 40,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: PieChart(
        PieChartData(
          sections: pieSections,
          centerSpaceRadius: 40,
          sectionsSpace: 4,
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildExpensesList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final expense = _expenses[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child:
              InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExpenseDetailScreen(expense: expense),
                        ),
                      );
                      _loadExpenses();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withAlpha(15)
                              : Colors.black.withAlpha(10),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).shadowColor.withAlpha(isDark ? 30 : 20),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(isDark ? 40 : 25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              color: Theme.of(context).colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expense.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${expense.category} • ${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '-\$${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(delay: (50 * index).ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
        );
      }, childCount: _expenses.length),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'No expenses yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first transaction',
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

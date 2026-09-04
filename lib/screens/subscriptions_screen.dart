import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../services/storage_service.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final StorageService _storage = StorageService();
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;
  String _currency = '\$';

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    final subs = await _storage.getSubscriptions();
    final profile = await _storage.getUserProfile();
    setState(() {
      _subscriptions = subs;
      _currency = profile['currency'] as String;
      _isLoading = false;
    });
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String cycle = 'Monthly';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Subscription'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (e.g. Netflix)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: cycle,
                items: ['Weekly', 'Monthly', 'Yearly']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => cycle = val);
                },
                decoration: const InputDecoration(labelText: 'Billing Cycle'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final t = titleController.text.trim();
                final amt =
                    double.tryParse(amountController.text.trim()) ?? 0.0;
                if (t.isNotEmpty && amt > 0) {
                  final sub = Subscription(
                    id: const Uuid().v4(),
                    title: t,
                    amount: amt,
                    cycle: cycle,
                  );
                  await _storage.addSubscription(sub);
                  if (context.mounted) Navigator.pop(context);
                  _loadSubscriptions();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subscriptions.isEmpty
          ? const Center(
              child: Text(
                'No active subscriptions tracking.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _subscriptions.length,
              itemBuilder: (context, index) {
                final sub = _subscriptions[index];
                return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withAlpha(20)
                              : Colors.black.withAlpha(10),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sub.cycle,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '$_currency${sub.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await _storage.deleteSubscription(sub.id);
                                  _loadSubscriptions();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .slideX(
                      begin: 0.5,
                      end: 0,
                      duration: 300.ms,
                      delay: (index * 50).ms,
                    )
                    .fadeIn();
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Subscription'),
      ),
    );
  }
}

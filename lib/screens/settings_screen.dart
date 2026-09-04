import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: themeNotifier.value == ThemeMode.dark,
            onChanged: (bool value) async {
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              await StorageService().setThemeMode(value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text('Set Monthly Budget'),
            subtitle: const Text('Track spending against a goal'),
            onTap: () => _showBudgetDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text('Securely end your session'),
            onTap: () async {
              await StorageService().setLoggedIn(false);
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Irreversibly delete all recorded expenses'),
            onTap: () => _showClearConfirmation(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showBudgetDialog(BuildContext context) async {
    final controller = TextEditingController();
    final currentBudget = await StorageService().getMonthlyBudget();
    if (currentBudget > 0) controller.text = currentBudget.toString();

    if (!context.mounted) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Enter limit (e.g. 5000)',
            prefixIcon: Icon(Icons.track_changes),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim()) ?? 0.0;
              StorageService().setMonthlyBudget(val);
              Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget updated successfully!')),
      );
    }
  }

  Future<void> _showClearConfirmation(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all your expenses. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await StorageService().clearAll();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared successfully')),
        );
      }
    }
  }
}

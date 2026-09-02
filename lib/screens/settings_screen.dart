import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/storage_service.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
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
            leading: const Icon(Icons.download, color: Colors.teal),
            title: const Text('Export to CSV'),
            subtitle: const Text('Share your expenses as a spreadsheet'),
            onTap: () => _exportToCSV(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            subtitle: const Text('Irreversibly delete all recorded expenses'),
            onTap: () => _showClearConfirmation(context),
          )
        ],
      ),
    );
  }

  Future<void> _exportToCSV(BuildContext context) async {
    final expenses = await StorageService().getExpenses();
    if (expenses.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No expenses to export')));
      }
      return;
    }
    
    StringBuffer buffer = StringBuffer();
    buffer.writeln('ID,Title,Amount,Category,Date');
    for (var e in expenses) {
      buffer.writeln('${e.id},"${e.title}",${e.amount},"${e.category}",${e.date.toIso8601String()}');
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/expenses_export.csv');
    await file.writeAsString(buffer.toString());

    if (context.mounted) {
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Expense Report',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }
  }

  Future<void> _showClearConfirmation(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will delete all your expenses. This action cannot be undone.'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared successfully')),
        );
      }
    }
  }
}

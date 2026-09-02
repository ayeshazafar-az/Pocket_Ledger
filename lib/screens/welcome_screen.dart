import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final balance = double.parse(_balanceController.text.trim());

    await StorageService().saveUserProfile(name, balance);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withAlpha(20)
              : Colors.black.withAlpha(20),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 2.5,
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:
                    [
                          Icon(
                            Icons.wallet_rounded,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ).animate().scale(
                            delay: 200.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Welcome to\nPocketLedger',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Let\'s set up your profile to effectively track your finances.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 48),
                          TextFormField(
                            controller: _nameController,
                            decoration: inputDecoration.copyWith(
                              hintText: 'What should we call you?',
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Please enter your name'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _balanceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: inputDecoration.copyWith(
                              hintText: 'Initial Total Balance',
                              prefixIcon: const Icon(
                                Icons.account_balance_wallet_outlined,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Enter your starting balance';
                              if (double.tryParse(value.trim()) == null)
                                return 'Enter a valid number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 48),
                          Container(
                            width: double.infinity,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(100),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _completeSetup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: _isSaving
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ]
                        .animate(interval: 100.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

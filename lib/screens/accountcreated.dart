import 'package:flutter/material.dart';

// Widget class (XState naming convention)
class AccountCreatedState extends StatefulWidget {
  const AccountCreatedState({super.key});

  @override
  State<AccountCreatedState> createState() => AccountCreatedPage();
}

// State class (XPage naming convention)
class AccountCreatedPage extends State<AccountCreatedState> {
  static const Color teal = Color(0xFF0F5C5C);

  @override
  Widget build(BuildContext context) {
    // Argument = the new user's full name (used for the greeting)
    final arg = ModalRoute.of(context)?.settings.arguments;
    final fullname = arg is String ? arg.trim() : '';
    final firstName = fullname.isEmpty ? '' : fullname.split(' ').first;

    return Scaffold(
      backgroundColor: teal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // Check badge
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(color: Color(0x26FFFFFF), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 24),

              // Headline + welcome line
              const Text('Account created',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
              const SizedBox(height: 10),
              Text(
                firstName.isEmpty
                    ? 'Welcome to Rentahan. Log in to start renting and lending gear.'
                    : 'Welcome to Rentahan, $firstName. Log in to start renting and lending gear.',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xD9FFFFFF), height: 1.4),
              ),

              const Spacer(flex: 3),

              // White pill: go to Login, clearing the stack
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: teal,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Go to login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
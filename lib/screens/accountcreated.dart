import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/widgets/applogo.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

class AccountCreatedState extends StatefulWidget {
  const AccountCreatedState({super.key});

  @override
  State<AccountCreatedState> createState() => AccountCreatedPage();
}

class AccountCreatedPage extends State<AccountCreatedState> {
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final fullname = arg is String ? arg.trim() : '';
    final firstName = fullname.isEmpty ? '' : fullname.split(' ').first;

    return Scaffold(
      backgroundColor: TopBar.mint,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const Center(child: AppLogo(size: 64)),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, 6))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(color: teal, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 20),
                    const Text('Account created',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.4)),
                    const SizedBox(height: 8),
                    Text(
                      firstName.isEmpty
                          ? 'Welcome to Pahiram. Log in to start renting and lending items.'
                          : 'Welcome to Pahiram, $firstName. Log in to start renting and lending items.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray, height: 1.45),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
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
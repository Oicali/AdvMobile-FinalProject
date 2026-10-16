import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/widgets/applogo.dart';
import 'package:advmobile_finalproject/widgets/inputfield.dart';

// Widget class (XState naming convention)
class LoginState extends StatefulWidget {
  const LoginState({super.key});

  @override
  State<LoginState> createState() => LoginPage();
}

// State class (XPage naming convention)
class LoginPage extends State<LoginState> {
  final TextEditingController usernameCtrl = TextEditingController(text: 'juan');
  final TextEditingController passwordCtrl = TextEditingController(text: 'password123');
  bool showError = false;

  static const Color teal = Color(0xFF0F5C5C);
  static const Color mint = Color(0xFF74C5A8); // header green from the Pahiram mockup (estimated)
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);

  // Free the controllers when the screen is removed
  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  // Check credentials against AllUsers, then route by account type
  void login() {
    final u = usernameCtrl.text.trim().toLowerCase();
    final p = passwordCtrl.text;
    final ok = AllUsers.users.any((x) => x['username'] == u && x['password'] == p);

    if (!ok) {
      setState(() => showError = true);
      return;
    }
    ActiveUser.username = u;
    Navigator.pushReplacementNamed(context, u == 'admin' ? '/demomenu' : '/home');
  }

  // Soft translucent circle used as header decoration
  Widget buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Color(0x26FFFFFF), shape: BoxShape.circle),
    );
  }

  // Small translucent pill with an icon, shown under the tagline
  Widget buildPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: const Color(0x40FFFFFF), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: teal),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: teal)),
        ],
      ),
    );
  }

  // Mint header: decorative circles, logo on a white card, tagline and feature pills
  Widget buildHeader() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: mint,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Stack(
        children: [
          Positioned(top: -50, right: -40, child: buildCircle(180)),
          Positioned(top: 100, left: -60, child: buildCircle(140)),
          Positioned(bottom: -30, right: 40, child: buildCircle(90)),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
              child: Column(
                children: [
                  // Logo sits directly on the mint
                  const AppLogo(size: 120),
                  const SizedBox(height: 16),
                  const Text("Borrow what you need. Lend what you don't use.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ink)),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      buildPill(Icons.inventory_2_outlined, 'List items'),
                      buildPill(Icons.calendar_today_outlined, 'Rent by the day'),
                      buildPill(Icons.verified_user_outlined, 'Refundable deposit'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      // Whole page scrolls so the keyboard never covers the buttons
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Welcome back',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  const Text('Log in to borrow or lend.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray)),
                  const SizedBox(height: 22),

                  // Username field (login uses username, not email)
                  InputField(
                    label: 'Username',
                    controller: usernameCtrl,
                    hint: 'juan',
                    hasError: showError,
                    onChanged: (_) {
                      if (showError) setState(() => showError = false);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field + error message after a failed login
                  InputField(
                    label: 'Password',
                    controller: passwordCtrl,
                    hint: 'Enter your password',
                    obscure: true,
                    errorText: showError ? 'Wrong username or password. Check both and try again.' : null,
                    onChanged: (_) {
                      if (showError) setState(() => showError = false);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Filled pill: log in
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Log in'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Outlined pill: go to Register
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: teal,
                        side: const BorderSide(color: teal, width: 1.5),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Create account'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Demo label: everything in the app is simulated
                  const Text('Front-end demo. Accounts, payments and ID checks are simulated.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
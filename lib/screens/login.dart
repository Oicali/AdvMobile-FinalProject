import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
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
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        // Center keeps the block mid-screen; the scroll view protects it when the keyboard opens
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App name (placeholder) + tagline
                const Text('Rentahan', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: teal, letterSpacing: -0.5)),
                const SizedBox(height: 10),
                const Text("Borrow what you need. Lend what you don't use.",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: gray)),
                const SizedBox(height: 24),

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
                const SizedBox(height: 22),

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
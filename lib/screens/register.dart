import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/widgets/inputfield.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

// Widget class (XState naming convention)
class RegisterState extends StatefulWidget {
  const RegisterState({super.key});

  @override
  State<RegisterState> createState() => RegisterPage();
}

// State class (XPage naming convention)
class RegisterPage extends State<RegisterState> {
  final TextEditingController fullnameCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  // Field key -> error message (a key present means that field is invalid)
  final Map<String, String> errors = {};

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color error = Color(0xFFD64545);

  // Free all controllers when the screen is removed
  @override
  void dispose() {
    fullnameCtrl.dispose();
    usernameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  // Validate, save the user, sign them in, then continue to the skippable address step
  void createAccount() {
    final fullname = fullnameCtrl.text.trim();
    final username = usernameCtrl.text.trim().toLowerCase();
    final phone = phoneCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;
    final confirm = confirmCtrl.text;
    final taken = AllUsers.users.any((u) => u['username'] == username);

    setState(() {
      errors.clear();
      if (fullname.isEmpty) errors['fullname'] = 'Enter your full name.';
      if (username.isEmpty || username.contains(' ')) {
        errors['username'] = 'Enter a username with no spaces.';
      } else if (taken) {
        errors['username'] = 'That username is taken. Try another.';
      }
      if (phone.replaceAll(RegExp(r'\D'), '').length < 10) errors['phone'] = 'Enter a valid mobile number.';
      if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) errors['email'] = 'Enter a valid email.';
      if (password.length < 8 || !RegExp(r'\d').hasMatch(password)) errors['password'] = 'At least 8 characters with a number.';
      if (confirm != password) errors['confirm'] = 'Passwords do not match.';
    });
    if (errors.isNotEmpty) return;

    // Account is NOT created yet; the address step creates it on Save or Skip
    Navigator.pushNamed(context, '/addeditaddress', arguments: {
      'onboarding': true,
      'newUser': {'fullname': fullname, 'username': username, 'password': password, 'email': email, 'phone': phone},
    });
  }

  // Clears one field's error as soon as the user edits it
  void clearError(String key) {
    if (errors.containsKey(key)) setState(() => errors.remove(key));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: Column(
        children: [
          // Pinned shared top bar (back arrow, logo, big title)
          const TopBar(title: 'Create account'),
          Expanded(
            child: SafeArea(
              top: false,
              // LayoutBuilder + IntrinsicHeight keeps the buttons at the bottom but lets the page scroll
              child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [


                      // Form fields
                      InputField(label: 'Full name', controller: fullnameCtrl, hint: 'Juan D.', errorText: errors['fullname'], onChanged: (_) => clearError('fullname')),
                      const SizedBox(height: 14),
                      InputField(label: 'Username', controller: usernameCtrl, hint: 'juan', errorText: errors['username'], onChanged: (_) => clearError('username')),
                      const SizedBox(height: 14),
                      InputField(label: 'Mobile number', controller: phoneCtrl, hint: '0917 000 0000', keyboard: TextInputType.phone, errorText: errors['phone'], onChanged: (_) => clearError('phone')),
                      const SizedBox(height: 14),
                      InputField(label: 'Email', controller: emailCtrl, hint: 'juan@email.com', keyboard: TextInputType.emailAddress, errorText: errors['email'], onChanged: (_) => clearError('email')),
                      const SizedBox(height: 14),
                      InputField(label: 'Password', controller: passwordCtrl, hint: 'Create a password', obscure: true, errorText: errors['password'], onChanged: (_) => clearError('password')),
                      const SizedBox(height: 14),
                      InputField(label: 'Confirm password', controller: confirmCtrl, hint: 'Re-enter your password', obscure: true, errorText: errors['confirm'], onChanged: (_) => clearError('confirm')),
                      const SizedBox(height: 14),



                      const Spacer(),
                      const SizedBox(height: 20),

                      // Filled pill: create the account and move to the address step
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: createAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: teal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          child: const Text('Next'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Outlined pill: back to Login (replace so screens don't stack)
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: teal,
                            side: const BorderSide(color: teal, width: 1.5),
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          child: const Text('I already have an account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
          ),
        ],
      ),
    );
  }
}
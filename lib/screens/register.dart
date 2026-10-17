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
  static const Color gray = Color(0xFF6A7776);
  static const Color tealSoft = Color(0xFFE3F0EE);
  static const Color barOff = Color(0xFFD5E3E0);

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

  Widget buildStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 5, decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(width: 6),
            Expanded(child: Container(height: 5, decoration: BoxDecoration(color: barOff, borderRadius: BorderRadius.circular(999)))),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Step 1 of 2 · Your details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
      ],
    );
  }

  Widget buildSection(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: teal),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ink)),
        ],
      ),
    );
  }
  // White rounded card that groups one section of the form
  Widget buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x140F5C5C), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
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
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            buildStep(),
                            const SizedBox(height: 18),

                            // Card 1: personal details
                            buildCard([
                              buildSection(Icons.person_outline, 'About you'),
                              InputField(label: 'Full name', controller: fullnameCtrl, hint: 'Juan D.', icon: Icons.badge_outlined, errorText: errors['fullname'], onChanged: (_) => clearError('fullname')),
                              const SizedBox(height: 14),
                              InputField(label: 'Username', controller: usernameCtrl, hint: 'juan', icon: Icons.alternate_email, errorText: errors['username'], onChanged: (_) => clearError('username')),
                              const SizedBox(height: 14),
                              InputField(label: 'Mobile number', controller: phoneCtrl, hint: '0917 000 0000', icon: Icons.phone_outlined, keyboard: TextInputType.phone, errorText: errors['phone'], onChanged: (_) => clearError('phone')),
                              const SizedBox(height: 14),
                              InputField(label: 'Email', controller: emailCtrl, hint: 'juan@email.com', icon: Icons.mail_outline, keyboard: TextInputType.emailAddress, errorText: errors['email'], onChanged: (_) => clearError('email')),
                            ]),
                            const SizedBox(height: 16),

                            // Card 2: password
                            buildCard([
                              buildSection(Icons.lock_outline, 'Secure your account'),
                              InputField(label: 'Password', controller: passwordCtrl, hint: 'Create a password', icon: Icons.lock_outline, obscure: true, errorText: errors['password'], onChanged: (_) => clearError('password')),
                              const SizedBox(height: 14),
                              InputField(label: 'Confirm password', controller: confirmCtrl, hint: 'Re-enter your password', icon: Icons.verified_user_outlined, obscure: true, errorText: errors['confirm'], onChanged: (_) => clearError('confirm')),
                            ]),

                            const Spacer(),
                            const SizedBox(height: 20),
                            // Demo label (SIMULATED)
                            const Text('Next, you can add an address or skip it. Account setup is simulated in this demo.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray, height: 1.4)),
                            const SizedBox(height: 14),

                            // Filled pill with a soft teal glow: create the account and move to the address step
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: const [BoxShadow(color: Color(0x550F5C5C), blurRadius: 14, offset: Offset(0, 6))],
                              ),
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
import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alladdresses.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/widgets/inputfield.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

class EditProfileState extends StatefulWidget {
  const EditProfileState({super.key});

  @override
  State<EditProfileState> createState() => EditProfilePage();
}

class EditProfilePage extends State<EditProfileState> {
  final TextEditingController fullnameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final Map<String, String> errors = {};
  Map<String, dynamic>? user;

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color tealSoft = Color(0xFFE3F0EE);

  @override
  void initState() {
    super.initState();
    user = AllUsers.byUsername(ActiveUser.username);
    if (user != null) {
      fullnameCtrl.text = user!['fullname'];
      phoneCtrl.text = user!['phone'];
      emailCtrl.text = user!['email'];
    }
  }

  @override
  void dispose() {
    fullnameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  String get defaultAddressText {
    final mine = AllAddresses.ownedBy(ActiveUser.username).where((a) => a['isDefault'] == true);
    if (mine.isEmpty) return '';
    return '${mine.first['street']}, ${mine.first['barangay']}';
  }

  String last10(String p) {
    final d = p.replaceAll(RegExp(r'\D'), '');
    return d.length >= 10 ? d.substring(d.length - 10) : d;
  }

  void save() {
    final fullname = fullnameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final phoneClean = phone.replaceAll(RegExp(r'[\s\-]'), '');
    final email = emailCtrl.text.trim();
    final emailTaken = AllUsers.users.any((u) => u['username'] != ActiveUser.username && (u['email'] as String).toLowerCase() == email.toLowerCase());
    final phoneTaken = AllUsers.users.any((u) => u['username'] != ActiveUser.username && (u['phone'] as String).isNotEmpty && last10(u['phone']) == last10(phoneClean));

    setState(() {
      errors.clear();

      if (fullname.isEmpty) {
        errors['fullname'] = 'Enter your full name.';
      } else if (fullname.length < 3) {
        errors['fullname'] = 'Full name must be at least 3 characters.';
      } else if (fullname.length > 40) {
        errors['fullname'] = 'Full name can be at most 40 characters.';
      }

      if (phoneClean.isEmpty) {
        errors['phone'] = 'Enter your mobile number.';
      } else if (!RegExp(r'^(09|\+639|639)\d{9}$').hasMatch(phoneClean)) {
        errors['phone'] = 'Use a PH mobile number like 0917 123 4567.';
      } else if (phoneTaken) {
        errors['phone'] = 'That mobile number is already registered.';
      }

      if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
        errors['email'] = 'Enter a valid email.';
      } else if (emailTaken) {
        errors['email'] = 'That email is already registered.';
      }
    });
    if (errors.isNotEmpty || user == null) return;

    user!['fullname'] = fullname;
    user!['phone'] = phoneClean;
    user!['email'] = email;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    Navigator.pop(context);
  }

  void clearError(String key) {
    if (errors.containsKey(key)) setState(() => errors.remove(key));
  }

  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
      );

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

  @override
  Widget build(BuildContext context) {
    final address = defaultAddressText;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: Column(
        children: [
          const TopBar(title: 'Edit profile'),
          Expanded(
            child: SafeArea(
              top: false,
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
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: cardStyle(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  buildSection(Icons.person_outline, 'About you'),
                                  InputField(label: 'Full name', controller: fullnameCtrl, hint: 'Juan D.', icon: Icons.badge_outlined, errorText: errors['fullname'], onChanged: (_) => clearError('fullname')),
                                  const SizedBox(height: 14),
                                  InputField(label: 'Mobile number', controller: phoneCtrl, hint: '0917 000 0000', icon: Icons.phone_outlined, keyboard: TextInputType.phone, errorText: errors['phone'], onChanged: (_) => clearError('phone')),
                                  const SizedBox(height: 14),
                                  InputField(label: 'Email', controller: emailCtrl, hint: 'juan@email.com', icon: Icons.mail_outline, keyboard: TextInputType.emailAddress, errorText: errors['email'], onChanged: (_) => clearError('email')),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            const SizedBox(height: 8),
                            buildSection(Icons.location_on_outlined, 'Default address'),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/myaddresses').then((_) => setState(() {})),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: cardStyle(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
                                      child: const Icon(Icons.location_on_outlined, size: 18, color: teal),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(address.isEmpty ? 'No address yet. Tap to add one.' : address,
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: address.isEmpty ? const Color(0xFF98A4A2) : ink)),
                                    ),
                                    const Icon(Icons.chevron_right, size: 18, color: gray),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: 20),
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: const [BoxShadow(color: Color(0x550F5C5C), blurRadius: 14, offset: Offset(0, 6))],
                              ),
                              child: ElevatedButton(
                                onPressed: save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: teal,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                                child: const Text('Save changes'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: teal,
                                  side: const BorderSide(color: teal, width: 1.5),
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                                child: const Text('Cancel'),
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
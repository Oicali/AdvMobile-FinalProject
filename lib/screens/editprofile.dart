import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alladdresses.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/widgets/inputfield.dart';

// Widget class (XState naming convention)
class EditProfileState extends StatefulWidget {
  const EditProfileState({super.key});

  @override
  State<EditProfileState> createState() => EditProfilePage();
}

// State class (XPage naming convention)
class EditProfilePage extends State<EditProfileState> {
  final TextEditingController fullnameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final Map<String, String> errors = {};
  Map<String, dynamic>? user;

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);

  // Prefill the fields with the signed-in user's current values
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

  // Free all controllers when the screen is removed
  @override
  void dispose() {
    fullnameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  // Default address shown read-only; it is stored in AllAddresses, not on the user
  String get defaultAddressText {
    final mine = AllAddresses.ownedBy(ActiveUser.username).where((a) => a['isDefault'] == true);
    if (mine.isEmpty) return '';
    return '${mine.first['street']}, ${mine.first['barangay']}';
  }

  // Validate, then write the new values into the user's map
  void save() {
    final fullname = fullnameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final email = emailCtrl.text.trim();

    setState(() {
      errors.clear();
      if (fullname.isEmpty) errors['fullname'] = 'Enter your full name.';
      if (phone.replaceAll(RegExp(r'\D'), '').length < 10) errors['phone'] = 'Enter a valid mobile number.';
      if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) errors['email'] = 'Enter a valid email.';
    });
    if (errors.isNotEmpty || user == null) return;

    user!['fullname'] = fullname;
    user!['phone'] = phone;
    user!['email'] = email;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    Navigator.pop(context);
  }

  // Clears one field's error as soon as the user edits it
  void clearError(String key) {
    if (errors.containsKey(key)) setState(() => errors.remove(key));
  }

  @override
  Widget build(BuildContext context) {
    final address = defaultAddressText;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        // LayoutBuilder + IntrinsicHeight keeps the buttons at the bottom but lets the page scroll
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Screen title
                      const Text('Edit profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5)),
                      const SizedBox(height: 18),

                      // Avatar placeholder + simulated photo button
                      Row(
                        children: [
                          const CircleAvatar(radius: 32, backgroundColor: Color(0xFFE3E8E6), child: Icon(Icons.person, size: 30, color: Color(0xFFB5C2BF))),
                          const SizedBox(width: 14),
                          OutlinedButton(
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo upload is simulated in this demo.'))),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: teal,
                              side: const BorderSide(color: teal, width: 1.5),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            child: const Text('Change photo'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Editable fields
                      InputField(label: 'Full name', controller: fullnameCtrl, hint: 'Juan D.', errorText: errors['fullname'], onChanged: (_) => clearError('fullname')),
                      const SizedBox(height: 14),
                      InputField(label: 'Mobile number', controller: phoneCtrl, hint: '0917 000 0000', keyboard: TextInputType.phone, errorText: errors['phone'], onChanged: (_) => clearError('phone')),
                      const SizedBox(height: 14),
                      InputField(label: 'Email', controller: emailCtrl, hint: 'juan@email.com', keyboard: TextInputType.emailAddress, errorText: errors['email'], onChanged: (_) => clearError('email')),
                      const SizedBox(height: 14),

                      // Default delivery address: read-only, tap to manage in My addresses
                      const Padding(
                        padding: EdgeInsets.only(left: 2, bottom: 7),
                        child: Text('Default delivery address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ink)),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/myaddresses').then((_) => setState(() {})),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3))],
                          ),
                          child: Row(
                            children: [
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

                      // Filled pill: save
                      SizedBox(
                        height: 52,
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

                      // Outlined pill: cancel
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
    );
  }
}
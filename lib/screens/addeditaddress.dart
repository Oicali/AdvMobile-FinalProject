import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alladdresses.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/inputfield.dart';

// Widget class (XState naming convention)
class AddEditAddressState extends StatefulWidget {
  const AddEditAddressState({super.key});

  @override
  State<AddEditAddressState> createState() => AddEditAddressPage();
}

// State class (XPage naming convention)
class AddEditAddressPage extends State<AddEditAddressState> {
  final TextEditingController labelCtrl = TextEditingController();
  final TextEditingController streetCtrl = TextEditingController();
  final TextEditingController barangayCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();

  bool isDefault = false;
  bool onboarding = false; // true when reached from Register
  Map<String, dynamic>? newUser; // pending account, only set during onboarding
  String? editId; // null = creating a new address
  bool loaded = false;
  final Map<String, String> errors = {};

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);

  // Read the route argument once: String = edit that id, Map with onboarding = from Register, null = create
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      editId = args;
      final a = AllAddresses.byId(args);
      if (a != null) {
        labelCtrl.text = a['label'];
        streetCtrl.text = a['street'];
        barangayCtrl.text = a['barangay'];
        cityCtrl.text = a['city'];
        isDefault = a['isDefault'] == true;
      }
    } else if (args is Map && args['onboarding'] == true) {
      onboarding = true;
      newUser = Map<String, dynamic>.from(args['newUser']);
      isDefault = true; // first address is always the default
    } else {
      // New address: default only if it's the user's first
      isDefault = AllAddresses.ownedBy(ActiveUser.username).isEmpty;
    }
  }

  // Free all controllers when the screen is removed
  @override
  void dispose() {
    labelCtrl.dispose();
    streetCtrl.dispose();
    barangayCtrl.dispose();
    cityCtrl.dispose();
    super.dispose();
  }

  // Who owns the address being saved (pending user during onboarding)
  String? get owner => onboarding ? newUser!['username'] as String : ActiveUser.username;

  // Create the pending account now (called only from Save or Skip)
  void createPendingAccount() {
    AllUsers.users.add({
      ...newUser!,
      'joined': AppSettings.demoDate,
      'verified': false,
    });
  }

  // Show the success screen and clear the stack so back can't return to the form
  void finishOnboarding() {
    Navigator.pushNamedAndRemoveUntil(context, '/accountcreated', (route) => false, arguments: newUser!['fullname']);
  }

  // Skip: create the account with no address
  void skip() {
    createPendingAccount();
    finishOnboarding();
  }

  // Validate, then create or update the address
  void save() {
    final label = labelCtrl.text.trim();
    final street = streetCtrl.text.trim();
    final barangay = barangayCtrl.text.trim();
    final city = cityCtrl.text.trim();

    setState(() {
      errors.clear();
      if (label.isEmpty) errors['label'] = 'Give this address a label.';
      if (street.isEmpty) errors['street'] = 'Enter the house no. and street.';
      if (barangay.isEmpty) errors['barangay'] = 'Enter the barangay.';
      if (city.isEmpty) errors['city'] = 'Enter the city or municipality.';
    });
    if (errors.isNotEmpty) return;

    // The account must exist before an address can belong to it
    if (onboarding) createPendingAccount();

    Map<String, dynamic> saved;
    if (editId != null) {
      saved = AllAddresses.byId(editId!)!;
      saved['label'] = label;
      saved['street'] = street;
      saved['barangay'] = barangay;
      saved['city'] = city;
      saved['isDefault'] = isDefault;
    } else {
      // Contact number comes from the user's profile phone
      final phone = AllUsers.byUsername(owner)?['phone'] ?? '';
      saved = {'id': AllAddresses.newId(), 'owner': owner, 'label': label, 'street': street, 'barangay': barangay, 'city': city, 'phone': phone, 'isDefault': isDefault};
      AllAddresses.addresses.add(saved);
    }

    // Only one default per owner; and never leave an owner with zero defaults
    final mine = AllAddresses.ownedBy(owner);
    if (saved['isDefault'] == true) {
      for (final a in mine) {
        if (a['id'] != saved['id']) a['isDefault'] = false;
      }
    } else if (!mine.any((a) => a['isDefault'] == true)) {
      saved['isDefault'] = true;
    }

    if (onboarding) {
      finishOnboarding();
    } else {
      Navigator.pop(context);
    }
  }

  // Clears one field's error as soon as the user edits it
  void clearError(String key) {
    if (errors.containsKey(key)) setState(() => errors.remove(key));
  }

  @override
  Widget build(BuildContext context) {
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
                      // Title switches between add and edit
                      Text(editId != null ? 'Edit address' : 'Add address',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5)),
                      const SizedBox(height: 20),

                      // Address fields
                      InputField(label: 'Label', controller: labelCtrl, hint: 'Home', errorText: errors['label'], onChanged: (_) => clearError('label')),
                      const SizedBox(height: 14),
                      InputField(label: 'House no. and street', controller: streetCtrl, hint: 'Blk 4 Lot 12, Mabini St.', errorText: errors['street'], onChanged: (_) => clearError('street')),
                      const SizedBox(height: 14),
                      InputField(label: 'Barangay', controller: barangayCtrl, hint: 'Brgy. San Roque', errorText: errors['barangay'], onChanged: (_) => clearError('barangay')),
                      const SizedBox(height: 14),
                      InputField(label: 'City / Municipality', controller: cityCtrl, hint: 'Your city', errorText: errors['city'], onChanged: (_) => clearError('city')),
                      const SizedBox(height: 14),

                      // Default address checkbox
                      InkWell(
                        onTap: () => setState(() => isDefault = !isDefault),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isDefault,
                              activeColor: teal,
                              visualDensity: VisualDensity.compact,
                              onChanged: (v) => setState(() => isDefault = v ?? false),
                            ),
                            const Text('Set as default address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ink)),
                          ],
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
                          child: const Text('Save address'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Outlined pill: Skip for now during onboarding, Cancel otherwise
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: onboarding ? skip : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: teal,
                            side: const BorderSide(color: teal, width: 1.5),
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          child: Text(onboarding ? 'Skip for now' : 'Cancel'),
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
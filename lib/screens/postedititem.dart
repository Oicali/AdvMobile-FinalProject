import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/widgets/inputfield.dart';

// Widget class (XState naming convention)
class PostEditItemState extends StatefulWidget {
  const PostEditItemState({super.key});

  @override
  State<PostEditItemState> createState() => PostEditItemPage();
}

// State class (XPage naming convention)
class PostEditItemPage extends State<PostEditItemState> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController rateCtrl = TextEditingController();
  final TextEditingController depositCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  final List<String> categories = ['Cameras', 'Tools', 'Camping', 'Electronics'];
  final List<String> conditions = ['Like new', 'Good', 'Fair'];
  String category = 'Cameras';
  String condition = 'Good';
  String? editId; // null = posting a new item
  bool loaded = false;
  final Map<String, String> errors = {};

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);

  // Read the route argument once: a String id = edit that item, none = create
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String) {
      final item = AllItems.byId(arg);
      if (item != null) {
        editId = arg;
        nameCtrl.text = item['name'];
        rateCtrl.text = item['dailyRate'].toString();
        depositCtrl.text = item['deposit'].toString();
        descCtrl.text = item['description'];
        category = item['category'];
        condition = item['condition'];
      }
    }
  }

  // Free all controllers when the screen is removed
  @override
  void dispose() {
    nameCtrl.dispose();
    rateCtrl.dispose();
    depositCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  // Validate, then create or update the item
  void save() {
    final name = nameCtrl.text.trim();
    final rate = int.tryParse(rateCtrl.text.replaceAll(',', '').trim());
    final deposit = int.tryParse(depositCtrl.text.replaceAll(',', '').trim());
    final desc = descCtrl.text.trim();

    setState(() {
      errors.clear();
      if (name.isEmpty) errors['name'] = 'Enter an item name.';
      if (rate == null || rate <= 0) errors['rate'] = 'Enter a rate above 0.';
      if (deposit == null || deposit < 0) errors['deposit'] = 'Enter a deposit.';
      if (desc.isEmpty) errors['desc'] = 'Add a short description.';

      // Money is calculated from these values, so they can't change mid-rental
      if (editId != null && errors.isEmpty && AllItems.isLocked(editId!)) {
        final old = AllItems.byId(editId!)!;
        if (rate != old['dailyRate'] || deposit != old['deposit']) {
          errors['lock'] = "Rate and deposit can't change while this item is rented out or has an approved booking.";
        }
      }
    });
    if (errors.isNotEmpty) return;

    if (editId != null) {
      final item = AllItems.byId(editId!)!;
      item['name'] = name;
      item['category'] = category;
      item['dailyRate'] = rate;
      item['deposit'] = deposit;
      item['condition'] = condition;
      item['description'] = desc;
    } else {
      AllItems.items.add({
        'id': AllItems.newId(),
        'owner': ActiveUser.username,
        'name': name,
        'category': category,
        'dailyRate': rate,
        'deposit': deposit,
        'condition': condition,
        'description': desc,
        'listed': true,
      });
    }
    Navigator.pop(context);
  }

  // Clears one field's error as soon as the user edits it
  void clearError(String key) {
    if (errors.containsKey(key) || errors.containsKey('lock')) {
      setState(() {
        errors.remove(key);
        errors.remove('lock');
      });
    }
  }

  // Rounded dropdown that matches the text fields
  Widget buildDropdown(String label, String value, List<String> options, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ink)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3))],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: gray),
              borderRadius: BorderRadius.circular(16),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ink),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Column(
          children: [
            // Scrolling form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title switches between post and edit
                    Text(editId != null ? 'Edit item' : 'Post item',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5)),
                    const SizedBox(height: 16),

                    // Dashed photo placeholder (simulated)
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo upload is simulated in this demo.'))),
                      child: CustomPaint(
                        painter: _DashedBorderPainter(),
                        child: Container(
                          height: 110,
                          alignment: Alignment.center,
                          child: const Text('Add photos (placeholder)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Item name
                    InputField(label: 'Item name', controller: nameCtrl, hint: 'Projector (HD)', errorText: errors['name'], onChanged: (_) => clearError('name')),
                    const SizedBox(height: 14),

                    // Category (needed so the item shows up under Browse chips)
                    buildDropdown('Category', category, categories, (v) => setState(() => category = v)),
                    const SizedBox(height: 14),

                    // Daily rate + deposit side by side
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: InputField(label: 'Daily rate (₱)', controller: rateCtrl, hint: '400', keyboard: TextInputType.number, errorText: errors['rate'], onChanged: (_) => clearError('rate'))),
                        const SizedBox(width: 12),
                        Expanded(child: InputField(label: 'Deposit (₱)', controller: depositCtrl, hint: '4,000', keyboard: TextInputType.number, errorText: errors['deposit'], onChanged: (_) => clearError('deposit'))),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Condition
                    buildDropdown('Condition', condition, conditions, (v) => setState(() => condition = v)),
                    const SizedBox(height: 14),

                    // Description (multi-line)
                    InputField(
                      label: 'Description',
                      controller: descCtrl,
                      hint: 'What is included, any limits, how to care for it',
                      keyboard: TextInputType.multiline,
                      maxLines: 4,
                      errorText: errors['desc'],
                      onChanged: (_) => clearError('desc'),
                    ),
                  ],
                ),
              ),
            ),

            // Pinned: price-lock message + save / cancel
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  if (errors['lock'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(errors['lock']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: error)),
                    ),
                  SizedBox(
                    width: double.infinity,
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
                      child: const Text('Save listing'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
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
          ],
        ),
      ),
    );
  }
}

// Draws the dashed rounded border for the photo box (Flutter has no built-in dashed border)
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB5C2BF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)));
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
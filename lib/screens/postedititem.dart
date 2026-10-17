import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/widgets/inputfield.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';


class PostEditItemState extends StatefulWidget {
  const PostEditItemState({super.key});

  @override
  State<PostEditItemState> createState() => PostEditItemPage();
}


class PostEditItemPage extends State<PostEditItemState> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController rateCtrl = TextEditingController();
  final TextEditingController depositCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  final List<String> categories = ['Cameras', 'Tools', 'Camping', 'Electronics'];
  final List<String> conditions = ['Like new', 'Good', 'Fair'];
  String category = 'Cameras';
  String condition = 'Good';
  String image = ''; 
  String? editId; 
  bool loaded = false;
  final Map<String, String> errors = {};

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color tealSoft = Color(0xFFE3F0EE);
  static const Color error = Color(0xFFD64545);

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
        image = (item['image'] ?? '') as String;
      }
    }
  }


  @override
  void dispose() {
    nameCtrl.dispose();
    rateCtrl.dispose();
    depositCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }


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
      item['image'] = image;
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
        'image': image,
      });
    }
    Navigator.pop(context);
  }


  void clearError(String key) {
    if (errors.containsKey(key) || errors.containsKey('lock')) {
      setState(() {
        errors.remove(key);
        errors.remove('lock');
      });
    }
  }

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
            color: const Color(0xFFF8FBFA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3ECEA), width: 1.5),
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

  List<String> get photos => AllItems.gallery;


  List<String> get rowPhotos {
    final row = photos.take(3).toList();
    if (image.isNotEmpty && !row.contains(image)) {
      row.insert(0, image);
      if (row.length > 3) row.removeLast();
    }
    return row;
  }


  Widget buildPhotoTile(String path) {
    final selected = image == path;
    return GestureDetector(
      onTap: () => setState(() => image = selected ? '' : path),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? teal : Colors.transparent, width: 2),
        ),
        child: ItemPhoto(item: {'image': path, 'category': category}, width: 66, height: 66, radius: 13, iconSize: 26),
      ),
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

  void openGallery() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose a photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
              const SizedBox(height: 2),
              const Text('Simulated gallery for this demo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: photos
                    .map((p) => GestureDetector(
                          onTap: () {
                            setState(() => image = p);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo added (simulated upload).')));
                          },
                          child: ItemPhoto(item: {'image': p, 'category': category}, radius: 14, iconSize: 28),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildUploadTile() {
    return GestureDetector(
       onTap: openGallery,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 76,
        height: 76,
        decoration: BoxDecoration(color: tealSoft, borderRadius: BorderRadius.circular(16)),
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_photo_alternate_outlined, size: 22, color: teal),
                SizedBox(height: 2),
                Text('Upload', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: teal)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
     
            TopBar(title: editId != null ? 'Edit item' : 'Post item'),

      
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [


                    buildSection(Icons.photo_camera_outlined, 'Photo'),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [buildUploadTile(), ...rowPhotos.map(buildPhotoTile)],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 2, top: 4),
                      child: Text('Tap Upload or a photo to choose one (tap a photo again for none). Upload is simulated.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray)),
                    ),
                    const SizedBox(height: 22),

        
                    // White card that holds the details fields
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    buildSection(Icons.info_outline, 'Details'),
                    InputField(label: 'Item name', controller: nameCtrl, hint: 'Projector (HD)', icon: Icons.inventory_2_outlined, errorText: errors['name'], onChanged: (_) => clearError('name')),
                    const SizedBox(height: 14),


                    buildDropdown('Category', category, categories, (v) => setState(() => category = v)),
                    const SizedBox(height: 14),





                    buildDropdown('Condition', condition, conditions, (v) => setState(() => condition = v)),
                    const SizedBox(height: 14),


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
                    const SizedBox(height: 16),
                    // White card that holds the pricing fields
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    buildSection(Icons.payments_outlined, 'Pricing'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: InputField(label: 'Daily rate (₱)', controller: rateCtrl, hint: '400', icon: Icons.sell_outlined, keyboard: TextInputType.number, errorText: errors['rate'], onChanged: (_) => clearError('rate'))),
                        const SizedBox(width: 12),
                        Expanded(child: InputField(label: 'Deposit (₱)', controller: depositCtrl, hint: '4,000', icon: Icons.savings_outlined, keyboard: TextInputType.number, errorText: errors['deposit'], onChanged: (_) => clearError('deposit'))),
                      ],
                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),


            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x1F0F5C5C), blurRadius: 16, offset: Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errors['lock'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(errors['lock']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: error)),
                    ),
                  Container(
                    width: double.infinity,
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
                      child: Text(editId != null ? 'Save changes' : 'Save listing'),
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

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F5C5C)
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
import 'package:flutter/material.dart';

// Shared item photo: bundled asset with rounded corners, grey icon box if missing
class ItemPhoto extends StatelessWidget {
  final Map<String, dynamic> item;
  final double? width;
  final double? height;
  final double radius;
  final double iconSize;

  const ItemPhoto({super.key, required this.item, this.width, this.height, this.radius = 0, this.iconSize = 28});

  static const Color boxColor = Color(0xFFE3E8E6);
  static const Color iconColor = Color(0xFFB5C2BF);

  // Fallback icon per category
  static IconData iconFor(String category) {
    switch (category) {
      case 'Cameras':
        return Icons.photo_camera_outlined;
      case 'Tools':
        return Icons.construction;
      case 'Camping':
        return Icons.terrain;
      default:
        return Icons.devices_other;
    }
  }

  // Mint gradient with the category icon in a white circle, shown when there is no image or it can't be loaded
  Widget buildFallback() {
    final circle = iconSize * 1.9;
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD5EFE6), Color(0xFFB7E0D2)],
        ),
      ),
      child: Container(
        width: circle,
        height: circle,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0x1F0F5C5C), blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Icon(iconFor('${item['category']}'), size: iconSize, color: const Color(0xFF0F5C5C)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = (item['image'] ?? '') as String;
    final Widget child = path.isEmpty
        ? buildFallback()
        : Image.asset(
            path,
            width: width,
            height: height,
            fit: BoxFit.cover,
            // Fade in once the first frame is ready
            frameBuilder: (context, child, frame, sync) => sync
                ? child
                : AnimatedOpacity(opacity: frame == null ? 0 : 1, duration: const Duration(milliseconds: 250), child: child),
            errorBuilder: (context, error, stack) => buildFallback(),
          );
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}
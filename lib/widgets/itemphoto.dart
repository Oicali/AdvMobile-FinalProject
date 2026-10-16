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

  // Grey box shown when there is no image or the file can't be loaded
  Widget buildFallback() {
    return Container(
      width: width,
      height: height,
      color: boxColor,
      alignment: Alignment.center,
      child: Icon(iconFor('${item['category']}'), size: iconSize, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = (item['image'] ?? '') as String;
    final Widget child = path.isEmpty
        ? buildFallback()
        : Image.asset(path, width: width, height: height, fit: BoxFit.cover, errorBuilder: (context, error, stack) => buildFallback());
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}
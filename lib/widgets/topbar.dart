import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/applogo.dart';

// Shared mint header.
// title == null -> Home mode: logo, demo date chip, saved shortcut.
// title given   -> other screens: [back arrow] logo [action], then the big title underneath.
// child sits at the bottom of the header (e.g. the Home search bar).
class TopBar extends StatelessWidget {
  final String? title;
  final Widget? action;
  final Widget? child;
  final VoidCallback? onReturn; // called after returning from the demo menu so the screen can refresh
  final bool showBack; // false on bottom-nav screens (Rentals, Listings, own Profile)

  const TopBar({super.key, this.title, this.action, this.child, this.onReturn, this.showBack = true});

  static const Color teal = Color(0xFF0F5C5C);
  static const Color mint = Color(0xFF74C5A8); // estimated from the mockup; change here to retheme every screen
  static const Color ink = Color(0xFF1B2626);

  // White circle holding one icon
  Widget circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: teal),
      ),
    );
  }

  // SIMULATED clock chip: shows demoDate and opens the Demo Menu (Home only)
  Widget buildDateChip(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/demomenu').then((_) => onReturn?.call()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event, size: 15, color: teal),
            const SizedBox(width: 5),
            Text(AppSettings.shortDate(AppSettings.demoDate),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: teal)),
          ],
        ),
      ),
    );
  }

  // Top row: Home mode or standard mode (the logo is on both)
  Widget buildRow(BuildContext context) {
    if (title == null) {
      return Row(
        children: [
          const AppLogo(size: 60),
          const Spacer(),
          buildDateChip(context),
          const SizedBox(width: 8),
          circleButton(Icons.favorite_border, () => Navigator.pushNamed(context, '/saveditems').then((_) => onReturn?.call())),
        ],
      );
    }
    return Row(
      children: [
        if (showBack && Navigator.canPop(context)) ...[
          circleButton(Icons.arrow_back, () => Navigator.pop(context)),
          const SizedBox(width: 12),
        ],
        const AppLogo(size: 60),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }

  // Soft translucent circle used as header decoration
  Widget buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Color(0x26FFFFFF), shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: mint,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          // Decorative circles sit behind the content and are clipped by the rounded corners
          Positioned(top: -45, right: -35, child: buildCircle(150)),
          Positioned(bottom: -35, left: 50, child: buildCircle(90)),
          Positioned(top: 30, left: -40, child: buildCircle(80)),

          // SafeArea(bottom: false) pushes content below the status bar while the mint still paints behind it
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  buildRow(context),

                  // Big screen title under the logo (not shown on Home)
                  if (title != null) ...[
                    const SizedBox(height: 14),
                    Text(title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5)),
                  ],

                  if (child != null) ...[
                    const SizedBox(height: 12),
                    child!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
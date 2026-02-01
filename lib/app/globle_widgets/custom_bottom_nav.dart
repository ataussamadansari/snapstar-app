import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapstar/app/core/themes/app_colors.dart';

import '../modules/main_view/controllers/main_controller.dart';

class CustomBottomNav extends StatelessWidget {
  final MainController controller;

  const CustomBottomNav({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Get.isDarkMode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, Icons.home, 0),
            _navItem(context, Icons.search, 1),
            _navItem(context, Icons.add, 2, isCenter: true),
            _navItem(context, Icons.movie_creation_rounded, 3),
            _navItem(context, Icons.person, 4),
          ],
        )),
      ),
    );
  }
  Widget _navItem(
      BuildContext context,
      IconData icon,
      int index, {
        bool isCenter = false,
      }) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = controller.selectedIndex.value == index;

    final activeColor = scheme.primary;
    final inactiveColor = scheme.onSurface.withOpacity(0.55);

    // 🔥 Profile Image Logic for Index 4 (Profile Tab)
    if (index == 4) {
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Obx(() {
          final photoUrl = controller.currentUser.value?.photoUrl;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? activeColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: scheme.surfaceVariant,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Icon(Icons.person, size: 26, color: inactiveColor)
                  : null,
            ),
          );
        }),
      );
    }

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: isCenter
            ? BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? activeColor : scheme.surface,
          boxShadow: [
            BoxShadow(
              color: activeColor.withOpacity(0.25),
              blurRadius: 8,
            ),
          ],
        )
            : null,
        child: Icon(
          icon,
          size: isCenter ? 32 : 26,
          color: isCenter
              ? (isSelected ? scheme.onPrimary : activeColor)
              : (isSelected ? activeColor : inactiveColor),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/reels_controller.dart';
import 'widgets/reel_item.dart';

class ReelsScreen extends GetView<ReelsController> {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.reels.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controller.reels.length,
          onPageChanged: controller.onPageChanged,
          itemBuilder: (_, index) {
            return ReelItem(
              post: controller.reels[index],
              isActive: controller.currentIndex.value == index,
            );
          },
        );
      }),
    );
  }
}

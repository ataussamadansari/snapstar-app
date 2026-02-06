import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/search_controller.dart';

class HashtagResults extends StatelessWidget {
  const HashtagResults({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SearchScreenController>();

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: c.hashtagPosts.length,
      itemBuilder: (_, i) {
        final post = c.hashtagPosts[i];
        return Image.network(
          post.thumbnailUrls.first,
          fit: BoxFit.cover,
        );
      },
    );
  }
}


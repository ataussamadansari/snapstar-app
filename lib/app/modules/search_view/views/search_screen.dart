import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart';
import 'widgets/hastag_result.dart';
import 'widgets/user_post_result.dart';

class SearchScreen extends GetView<SearchScreenController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search",
            border: InputBorder.none,
          ),
          onChanged: controller.onQueryChanged,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        switch (controller.searchType.value) {
          case SearchType.hashtags:
            return HashtagResults();
          default:
            return UserPostResults();
        }
      }),
    );
  }
}

import 'dart:async';
import 'package:get/get.dart';

import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/search_repository.dart';

enum SearchType { users, posts, hashtags }

class SearchScreenController extends GetxController {
  final SearchRepository _repo = SearchRepository();

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxList<PostModel> hashtagPosts = <PostModel>[].obs;

  final RxBool isLoading = false.obs;
  final Rx<SearchType> searchType = SearchType.users.obs;

  Timer? _debounce;

  void onQueryChanged(String query) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(query.trim().toLowerCase());
    });
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      users.clear();
      posts.clear();
      hashtagPosts.clear();
      return;
    }

    isLoading.value = true;

    if (query.startsWith('#')) {
      searchType.value = SearchType.hashtags;
      hashtagPosts.value =
      await _repo.searchHashtags(query.replaceFirst('#', ''));
    } else {
      searchType.value = SearchType.users;
      users.value = await _repo.searchUsers(query);
      posts.value = await _repo.searchPosts(query);
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}

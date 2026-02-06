import 'dart:async';
import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../models/user_model.dart';
import '../repositories/search_repository.dart';

class SearchProvider extends ChangeNotifier {
  final SearchRepository _repo;

  SearchProvider(this._repo);

  List<UserModel> users = [];
  List<PostModel> posts = [];
  List<PostModel> hashtagPosts = [];

  bool isLoading = false;
  Timer? _debounce;

  void onQueryChanged(String query) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(query.toLowerCase());
    });
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      users = [];
      posts = [];
      hashtagPosts = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    if (query.startsWith('#')) {
      hashtagPosts =
      await _repo.searchHashtags(query.replaceFirst('#', ''));
    } else {
      users = await _repo.searchUsers(query);
      posts = await _repo.searchPosts(query);
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}


import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/post_model.dart';
import '../../../data/repositories/reels_repository.dart';

class ReelsController extends GetxController {
  final ReelsRepository _repo = ReelsRepository();

  final reels = <PostModel>[].obs;
  final isLoading = false.obs;
  final hasMore = true.obs;

  /// 👇 WHICH REEL IS ACTIVE
  final currentIndex = (-1).obs;

  DocumentSnapshot? _lastDoc;

  @override
  void onInit() {
    super.onInit();
    loadInitialReels();
  }

  Future<void> loadInitialReels() async {
    if (isLoading.value) return;

    isLoading.value = true;

    final result = await _repo.fetchReels();
    reels.assignAll(result.reels);
    _lastDoc = result.lastDoc;

    hasMore.value = result.reels.isNotEmpty;
    isLoading.value = false;

    /// 🔥 auto-play first reel only if reels tab active
    if (currentIndex.value == -1 && reels.isNotEmpty) {
      currentIndex.value = 0;
    }
  }

  Future<void> loadMoreReels() async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    final result = await _repo.fetchReels(lastDoc: _lastDoc);
    reels.addAll(result.reels);
    _lastDoc = result.lastDoc;

    if (result.reels.isEmpty) hasMore.value = false;
    isLoading.value = false;
  }

  /// 🔥 PAGE SWIPE
  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  /// 🔥 WHEN USER LEAVES REELS TAB
  void pauseReels() {
    currentIndex.value = -1;
  }

  /// 🔥 WHEN USER ENTERS REELS TAB
  void resumeReels() {
    if (reels.isNotEmpty) {
      currentIndex.value = 0;
    }
  }
}

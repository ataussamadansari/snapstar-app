import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';

class HomeRepository {
  final PostProvider _postProvider = PostProvider();
  final UserProvider _userProvider = UserProvider();

  final String myUid = firebaseAuth.currentUser!.uid;

  /// 1️⃣ CURRENT USER
  Future<UserModel?> getCurrentUser() {
    return _userProvider.getUser(myUid);
  }

  /// 2️⃣ GLOBAL FEED (Explore)
  Stream<List<PostModel>> getGlobalFeed() {
    return _postProvider.getGlobalPosts().map(
          (list) => list
          .map((e) => PostModel.fromMap(e as Map<String, dynamic>))
          .where((p) => p.userId != myUid)
          .toList(),
    );
  }

  /// 3️⃣ FOLLOWING FEED (Main Home)
  Future<List<PostModel>> getFollowingFeed({
    int limit = 10,
    DocumentSnapshot? lastDoc,
  }) async {
    final followingIds = await _userProvider.getFollowingIds(myUid);
    if (followingIds.isEmpty) return [];

    Query query = db
        .collection('posts')
        .where('userId', whereIn: followingIds.take(10).toList())
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snap = await query.get();
    return snap.docs
        .map((d) => PostModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  /// 4️⃣ REELS FEED
  Stream<List<PostModel>> getReelsFeed() {
    return _postProvider.getGlobalPosts().map(
          (list) => list
          .map((e) => PostModel.fromMap(e as Map<String, dynamic>))
          .where((p) =>
      p.mediaType == MediaType.video &&
          p.userId != myUid)
          .toList(),
    );
  }

  Future<List<UserModel>> getSuggestions({int limit = 10}) async {
    final Map<String, UserModel> uniqueMap = {};
    final followingIds = await _userProvider.getFollowingIds(myUid);

    // 1. Incoming Requests (User B)
    final requestIds = await _userProvider.getIncomingRequestIds(myUid);
    for (var id in requestIds) {
      if (!followingIds.contains(id)) {
        var u = await _userProvider.getUser(id);
        if (u != null) uniqueMap[u.uid] = u;
      }
    }

    // 2. Followers (Follow Back)
    if (uniqueMap.length < limit) {
      final followers = await _userProvider.getFollowerIds(myUid);
      for (var id in followers) {
        if (!followingIds.contains(id) && !uniqueMap.containsKey(id)) {
          var u = await _userProvider.getUser(id);
          if (u != null) uniqueMap[u.uid] = u;
        }
      }
    }

    // 3. 🔥 Fix: Random Users (Always add if space remains)
    if (uniqueMap.length < limit) {
      final randoms = await _userProvider.getRandomUsers(myUid: myUid, limit: limit);
      for (var u in randoms) {
        if (!followingIds.contains(u.uid) && !uniqueMap.containsKey(u.uid)) {
          uniqueMap[u.uid] = u;
        }
        if (uniqueMap.length >= limit) break; // Limit check inside loop
      }
    }

    return uniqueMap.values.toList();
  }

  Future<List<UserModel>> getSuggestions2({int limit = 10}) async {
    final followingIds = await _userProvider.getFollowingIds(myUid);
    // Map use karne se duplicate UID wale users automatically merge ho jayenge
    final Map<String, UserModel> uniqueSuggestions = {};

    /// 1. PEHLE: Follow Back (Wo log jo mujhe follow karte hain par main unhe nahi)
    final followers = await _userProvider.getFollowerIds(myUid); //
    for (final f in followers) {
      if (!followingIds.contains(f)) {
        final u = await _userProvider.getUser(f);
        if (u != null) uniqueSuggestions[u.uid] = u;
      }
      if (uniqueSuggestions.length >= limit) break;
    }

    /// 2. DOOSRA: Friends of Friends
    if (uniqueSuggestions.length < limit) {
      for (final uid in followingIds) {
        final theirFollowing = await _userProvider.getFollowingIds(uid);
        for (final id in theirFollowing) {
          if (id != myUid && !followingIds.contains(id) && !uniqueSuggestions.containsKey(id)) {
            final user = await _userProvider.getUser(id);
            if (user != null) uniqueSuggestions[user.uid] = user;
          }
        }
        if (uniqueSuggestions.length >= limit) break;
      }
    }

    /// 3. TEESRA: Random fallback
    if (uniqueSuggestions.length < limit) {
      final randomUsers = await _userProvider.getRandomUsers(myUid: myUid);
      for (var u in randomUsers) {
        if (!followingIds.contains(u.uid) && !uniqueSuggestions.containsKey(u.uid)) {
          uniqueSuggestions[u.uid] = u;
        }
      }
    }

    return uniqueSuggestions.values.toList();
  }

  /// 5️⃣ USER SUGGESTIONS
  Future<List<UserModel>> getSuggestions1({int limit = 10}) async {
    // 1. Get IDs of people I already follow to exclude them
    final followingIds = await _userProvider.getFollowingIds(myUid);

    // Use a Map to store unique users, keyed by their UID to prevent duplicates
    final Map<String, UserModel> uniqueSuggestions = {};

    /// 2. PRIORITIZE: Follow Back (People who follow me but I don't follow them)
    final followerIds = await _userProvider.getFollowerIds(myUid);
    for (final fId in followerIds) {
      if (!followingIds.contains(fId)) {
        final user = await _userProvider.getUser(fId);
        if (user != null) {
          uniqueSuggestions[user.uid] = user;
        }
      }
      if (uniqueSuggestions.length >= limit) break;
    }

    /// 3. SECONDARY: Friends of Friends
    if (uniqueSuggestions.length < limit) {
      for (final uid in followingIds) {
        final theirFollowing = await _userProvider.getFollowingIds(uid);
        for (final id in theirFollowing) {
          if (id != myUid && !followingIds.contains(id) && !uniqueSuggestions.containsKey(id)) {
            final user = await _userProvider.getUser(id);
            if (user != null) uniqueSuggestions[user.uid] = user;
          }
          if (uniqueSuggestions.length >= limit) break;
        }
        if (uniqueSuggestions.length >= limit) break;
      }
    }

    /// 4. FALLBACK: Random Users
    if (uniqueSuggestions.length < limit) {
      final randoms = await _userProvider.getRandomUsers(myUid: myUid, limit: limit);
      for (final rUser in randoms) {
        if (!followingIds.contains(rUser.uid) && !uniqueSuggestions.containsKey(rUser.uid)) {
          uniqueSuggestions[rUser.uid] = rUser;
        }
        if (uniqueSuggestions.length >= limit) break;
      }
    }

    return uniqueSuggestions.values.toList();
  }
}

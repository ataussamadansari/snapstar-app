import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/subscribe_state.dart';
import '../models/subscribe_model.dart';
import '../models/user_model.dart';
import '../providers/subscriber_provider.dart';

class SubscriberRepository {
  final SubscriberProvider provider;
  final _supabase = Supabase.instance.client;

  SubscriberRepository(this.provider);

  Future<SubscribeState> getRelationStatus(String targetUserId) async {
    final myId = _supabase.auth.currentUser!.id;

    final iSubscribed = await provider.getSubscription(
      subscriberId: myId,
      subscribedId: targetUserId,
    );

    final theySubscribed = await provider.getSubscription(
      subscriberId: targetUserId,
      subscribedId: myId,
    );

    if (iSubscribed != null && theySubscribed != null) {
      return SubscribeState.mutual;
    } else if (iSubscribed != null) {
      return SubscribeState.subscribed;
    } else if (theySubscribed != null) {
      return SubscribeState.subscribeBack;
    } else {
      return SubscribeState.none;
    }
  }


  Future<List<UserModel>> getSuggestedUsers({
    required int limit,
    required int offset,
  }) async {
    final myId = _supabase.auth.currentUser!.id;

    // 1️⃣ Already subscribed users fetch karo
    final subscribed = await provider.getSubscribing(myId);

    final subscribedIds =
    subscribed.map((e) => e['subscribed_id']).toList();

    // 2️⃣ Users table se sab lao except self
    final res = await _supabase
        .from('users')
        .select()
        .neq('id', myId)
        .range(offset, offset + limit - 1);

    final allUsers =
    List<Map<String, dynamic>>.from(res);

    // 3️⃣ Filter karo jo already subscribed hain
    final filtered = allUsers
        .where((u) => !subscribedIds.contains(u['id']))
        .map((u) => UserModel.fromJson(u))
        .toList();

    return filtered;
  }


  /// Toggle subscribe
  Future<bool> toggleSubscribe(String targetUserId) async {
    final myId = _supabase.auth.currentUser!.id;

    final existing = await provider.getSubscription(
      subscriberId: myId,
      subscribedId: targetUserId,
    );

    if (existing != null) {
      await provider.unsubscribe(
        subscriberId: myId,
        subscribedId: targetUserId,
      );
      return false; // unsubscribed
    } else {
      await provider.subscribe({
        'subscriber_id': myId,
        'subscribed_id': targetUserId,
      });
      return true; // subscribed
    }
  }

  /// Check if subscribed
  Future<bool> isSubscribed(String targetUserId) async {
    final myId = _supabase.auth.currentUser!.id;

    final existing = await provider.getSubscription(
      subscriberId: myId,
      subscribedId: targetUserId,
    );

    return existing != null;
  }

  /// Get subscribers
  Future<List<SubscribeModel>> getSubscribers(String userId) async {
    final raw = await provider.getSubscribers(userId);
    return raw.map((e) => SubscribeModel.fromJson(e)).toList();
  }

  /// Get subscribing
  Future<List<SubscribeModel>> getSubscribing(String userId) async {
    final raw = await provider.getSubscribing(userId);
    return raw.map((e) => SubscribeModel.fromJson(e)).toList();
  }

  Future<List<UserModel>> fetchSubscribersUsers(String userId) async {
    final raw = await provider.getSubscribers(userId);

    return raw
        .map((e) => UserModel.fromJson(
        e['users'])) // join ke through user data
        .toList();
  }

  Future<List<UserModel>> fetchSubscribingUsers(String userId) async {
    final raw = await provider.getSubscribing(userId);

    return raw
        .map((e) => UserModel.fromJson(
        e['users']))
        .toList();
  }

}

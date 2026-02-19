import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriberProvider {
  final _supabase = Supabase.instance.client;

  /// Subscribe user
  Future<void> subscribe(Map<String, dynamic> data) async {
    await _supabase.from('subscribes').insert(data);
  }

  /// Unsubscribe
  Future<void> unsubscribe({
    required String subscriberId,
    required String subscribedId,
  }) async {
    await _supabase
        .from('subscribes')
        .delete()
        .eq('subscriber_id', subscriberId)
        .eq('subscribed_id', subscribedId);
  }

  /// Check subscription
  Future<Map<String, dynamic>?> getSubscription({
    required String subscriberId,
    required String subscribedId,
  }) async {
    return await _supabase
        .from('subscribes')
        .select()
        .eq('subscriber_id', subscriberId)
        .eq('subscribed_id', subscribedId)
        .maybeSingle();
  }

  /// Get subscribers list
  Future<List<Map<String, dynamic>>> getSubscribers(String userId) async {
    final res = await _supabase
        .from('subscribes')
        .select('*, users!subscribes_subscriber_id_fkey(*)')
        .eq('subscribed_id', userId);

    return List<Map<String, dynamic>>.from(res);
  }

  /// Get subscribing list
  Future<List<Map<String, dynamic>>> getSubscribing(String userId) async {
    final res = await _supabase
        .from('subscribes')
        .select('*, users!subscribes_subscribed_id_fkey(*)')
        .eq('subscriber_id', userId);

    return List<Map<String, dynamic>>.from(res);
  }
}

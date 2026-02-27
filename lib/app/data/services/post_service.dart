import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService extends GetxService {
  final SupabaseClient _client = Supabase.instance.client;

  RealtimeChannel? _channel;

  void subscribeToPosts({
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(Map<String, dynamic>) onDelete,
  }) {
    _channel = _client
        .channel('public:posts')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'posts',
      callback: (payload) {
        onInsert(payload.newRecord);
      },
    )
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'posts',
      callback: (payload) {
        onUpdate(payload.newRecord);
      },
    )
        .onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: 'posts',
      callback: (payload) {
        onDelete(payload.oldRecord);
      },
    )
        .subscribe();
  }

  void unsubscribe() {
    _channel?.unsubscribe();
  }
}
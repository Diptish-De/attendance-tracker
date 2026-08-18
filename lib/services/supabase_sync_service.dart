import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'attendance_store.dart';
import 'supabase_config.dart';

class SupabaseSyncService {
  final AttendanceDataStore store;
  RealtimeChannel? _roomChannel;
  String? _subscribedRoomId;

  SupabaseSyncService(this.store) {
    _initCloudSync();
  }

  SupabaseClient? get _client {
    try {
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> _initCloudSync() async {
    final client = _client;
    if (client == null) return;

    try {
      // 1. Sync User Profile to Supabase
      await syncProfileToCloud();

      // 2. Clean up server-side expired records older than 24h
      await cleanup24hExpiredData();

      // 3. Subscribe to active squad room
      if (store.activeSquad != null) {
        subscribeToSquadRoom(store.activeSquad!.id);
      }
    } catch (e) {
      debugPrint('Supabase auto-sync note: $e');
    }
  }

  /// Clean up messages and polls older than 24 hours in Supabase
  Future<void> cleanup24hExpiredData() async {
    final client = _client;
    if (client == null) return;

    try {
      final expiryThreshold = DateTime.now().subtract(const Duration(hours: 24)).toIso8601String();
      await client.from('squad_messages').delete().lt('created_at', expiryThreshold);
      await client.from('squad_polls').delete().lt('created_at', expiryThreshold);
    } catch (e) {
      debugPrint('Cleanup 24h error: $e');
    }
  }

  /// Sync student profile
  Future<void> syncProfileToCloud() async {
    final client = _client;
    if (client == null) return;

    try {
      final studentId = store.studentName.toLowerCase().replaceAll(' ', '_');
      await client.from('profiles').upsert({
        'id': studentId,
        'name': store.studentName,
        'degree': store.degree,
        'course': store.course,
        'semester': store.semester,
        'overall_pct': store.overallPercentage,
        'streak_days': store.streakDays,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Also sync all subject records and attendance log history
      await syncAllAttendanceDataToCloud();
    } catch (e) {
      debugPrint('Profile sync error: $e');
    }
  }

  /// Sync all subjects and individual attendance logs to Supabase
  Future<void> syncAllAttendanceDataToCloud() async {
    final client = _client;
    if (client == null) return;

    final studentId = store.studentName.toLowerCase().replaceAll(' ', '_');

    try {
      for (final s in store.subjects) {
        // 1. Upsert Subject
        await client.from('subjects').upsert({
          'id': '${studentId}_${s.id}',
          'student_id': studentId,
          'subject_id': s.id,
          'name': s.name,
          'faculty': s.faculty,
          'icon': s.icon,
          'attended': s.attended,
          'total': s.total,
          'min_req_pct': s.minRequiredPercentage,
          'updated_at': DateTime.now().toIso8601String(),
        });

        // 2. Upsert Individual Attendance Session Logs
        for (int i = 0; i < s.history.length; i++) {
          final h = s.history[i];
          final logId = '${studentId}_${s.id}_${h.date.replaceAll(' ', '_').replaceAll(',', '')}_$i';
          await client.from('attendance_logs').upsert({
            'id': logId,
            'student_id': studentId,
            'subject_id': s.id,
            'subject_name': s.name,
            'date': h.date,
            'day': h.day,
            'time': h.time,
            'periods': h.periods,
            'status': h.status,
            'note': h.note,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint('Attendance log sync note: $e');
    }
  }

  /// Subscribe to Realtime room messages and polls
  void subscribeToSquadRoom(String roomId) {
    final client = _client;
    if (client == null) return;

    if (_subscribedRoomId == roomId && _roomChannel != null) return;

    // Unsubscribe from previous room if any
    if (_roomChannel != null) {
      client.removeChannel(_roomChannel!);
      _roomChannel = null;
    }

    _subscribedRoomId = roomId;

    try {
      _roomChannel = client
          .channel('squad_room_$roomId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'squad_messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'room_id',
              value: roomId,
            ),
            callback: (payload) {
              final newRecord = payload.newRecord;
              final senderId = newRecord['sender_id'] as String?;
              // Ignore own messages already added locally
              if (senderId == 'me' || senderId == store.studentName) return;

              final msg = ChatMessage(
                id: newRecord['id'] ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
                senderId: senderId ?? 'peer',
                senderName: newRecord['sender_name'] ?? 'Friend',
                senderAvatar: newRecord['sender_avatar'] ?? '🎓',
                text: newRecord['text'] ?? '',
                timestamp: newRecord['time'] ?? 'Just now',
                isBunkAlert: newRecord['is_bunk_alert'] ?? false,
              );

              final squad = store.squadGroups.where((s) => s.id == roomId).firstOrNull;
              if (squad != null && !squad.messages.any((m) => m.id == msg.id)) {
                squad.messages.add(msg);
                store.saveToPreferences();
                store.notifyListeners();
              }
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Realtime channel error: $e');
    }
  }

  /// Broadcast message to Supabase
  Future<void> sendCloudMessage(String roomId, ChatMessage message) async {
    final client = _client;
    if (client == null) return;

    try {
      await client.from('squad_messages').insert({
        'id': message.id,
        'room_id': roomId,
        'sender_id': store.studentName,
        'sender_name': message.senderName,
        'sender_avatar': message.senderAvatar,
        'text': message.text,
        'time': message.timestamp,
        'is_bunk_alert': message.isBunkAlert,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Send cloud message note: $e');
    }
  }

  /// Publish a Bunk Poll to Supabase
  Future<void> sendCloudPoll(String roomId, BunkPoll poll) async {
    final client = _client;
    if (client == null) return;

    try {
      await client.from('squad_polls').insert({
        'id': poll.id,
        'room_id': roomId,
        'question': poll.question,
        'subject': poll.subject,
        'creator': poll.creator,
        'bunk_votes': poll.bunkVotes,
        'attend_votes': poll.attendVotes,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Send cloud poll note: $e');
    }
  }
}

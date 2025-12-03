import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/chat_models.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // ============================================
  // CONVERSATIONS
  // ============================================

  /// Get all conversations for current user
  Future<List<Conversation>> getMyConversations(String userId) async {
    try {
      print('🔍 Loading conversations for user: $userId');
      
      // Get conversation IDs where user is participant
      final participations = await client
          .from(SupabaseConfig.conversationParticipantsTable)
          .select('conversation_id, last_read_at')
          .eq('user_id', userId);

      print('📊 Found ${participations.length} participations');

      if (participations.isEmpty) return [];

      final convIds =
          participations.map((p) => p['conversation_id']).toList();
      final lastReadMap = {
        for (var p in participations)
          p['conversation_id']: p['last_read_at']
      };

      // Get conversations with last message
      final conversations = await client
          .from(SupabaseConfig.conversationsTable)
          .select()
          .inFilter('id', convIds)
          .order('last_message_at', ascending: false);

      print('💬 Loaded ${conversations.length} conversations');

      // Get unread counts for each conversation
      List<Conversation> result = [];
      for (var conv in conversations) {
        final convId = conv['id'];
        final lastRead = lastReadMap[convId];

        // Count unread messages
        int unreadCount = 0;
        try {
          var unreadQuery = client
              .from(SupabaseConfig.messagesTable)
              .select()
              .eq('conversation_id', convId)
              .neq('sender_id', userId);

          if (lastRead != null) {
            unreadQuery = unreadQuery.gt('created_at', lastRead);
          }

          final unreadMessages = await unreadQuery;
          unreadCount = (unreadMessages as List).length;
        } catch (e) {
          print('⚠️ Error counting unread messages: $e');
          unreadCount = 0;
        }

        conv['unread_count'] = unreadCount;

        // FIX: Untuk private chat, tampilkan nama lawan bicara
        if (conv['type'] == 'private') {
          // Get participants
          final participants = await client
              .from(SupabaseConfig.conversationParticipantsTable)
              .select('user_id')
              .eq('conversation_id', convId);

          // Find the OTHER user (bukan current user)
          final otherUserId = participants
              .where((p) => p['user_id'] != userId)
              .map((p) => p['user_id'])
              .firstOrNull;

          if (otherUserId != null) {
            // Get other user's name
            final otherUser = await client
                .from('users')
                .select('full_name, avatar_url')
                .eq('id', otherUserId)
                .maybeSingle();

            if (otherUser != null) {
              conv['name'] = otherUser['full_name'] ?? 'User';
              conv['avatar_url'] = otherUser['avatar_url'];
            }
          }
        }

        result.add(Conversation.fromJson(conv));
      }

      print('✅ Returning ${result.length} conversations');
      return result;
    } catch (e) {
      print('❌ Error fetching conversations: $e');
      return [];
    }
  }

  /// Get or create private conversation between two users
  Future<String? > getOrCreatePrivateConversation(
    String userId1,
    String userId2,
  ) async {
    try {
      print('🔍 Getting/creating private chat between $userId1 and $userId2');
      
      // Check if conversation already exists
      final existingParticipations = await client
          .from(SupabaseConfig.conversationParticipantsTable)
          .select('conversation_id')
          .inFilter('user_id', [userId1, userId2]);

      print('📊 Found ${existingParticipations.length} existing participations');

      // Find conversation where both users are participants
      Map<String, int> convCounts = {};
      for (var p in existingParticipations) {
        final convId = p['conversation_id'];
        convCounts[convId] = (convCounts[convId] ??  0) + 1;
      }

      // If found conversation with both users
      for (var entry in convCounts.entries) {
        if (entry.value == 2) {
          // Verify it's a private conversation
          final conv = await client
              .from(SupabaseConfig.conversationsTable)
              .select()
              .eq('id', entry. key)
              .eq('type', 'private')
              .maybeSingle();

          if (conv != null) {
            print('✅ Found existing private conversation: ${entry.key}');
            return entry.key;
          }
        }
      }

      print('🆕 Creating new private conversation');

      // Create new private conversation
      // Get user names for conversation name
      final user2 = await client
          .from('users')
          .select('full_name')
          .eq('id', userId2)
          .single();

      print('👤 User 2 name: ${user2['full_name']}');

      final newConv = await client
          .from(SupabaseConfig.conversationsTable)
          .insert({
            'type': 'private',
            'name': user2['full_name'] ?? 'Private Chat',
          })
          .select()
          . single();

      print('✅ Created conversation: ${newConv['id']}');

      // Add participants
      await client
          .from(SupabaseConfig.conversationParticipantsTable)
          .insert([
            {'conversation_id': newConv['id'], 'user_id': userId1},
            {'conversation_id': newConv['id'], 'user_id': userId2},
          ]);

      print('✅ Added participants to conversation');

      return newConv['id'];
    } catch (e) {
      print('❌ Error creating private conversation: $e');
      print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Create group conversation for project
  Future<String?> createProjectGroupConversation(
    String projectId,
    String projectTitle,
    List<String> memberIds,
  ) async {
    try {
      print('🆕 Creating group chat for project: $projectTitle');
      print('👥 Members: $memberIds');

      // Create conversation
      final newConv = await client
          .from(SupabaseConfig.conversationsTable)
          .insert({
            'type': 'group',
            'name': projectTitle,
          })
          .select()
          .single();

      print('✅ Created group conversation: ${newConv['id']}');

      if (memberIds.isEmpty) {
        print('⚠️ No members to add to group');
        return newConv['id'];
      }

      // Add all members as participants
      await client
          . from(SupabaseConfig. conversationParticipantsTable)
          .insert(
            memberIds.map((userId) => {
              'conversation_id': newConv['id'],
              'user_id': userId,
            }).toList(),
          );

      print('✅ Added ${memberIds.length} participants to group');

      return newConv['id'];
    } catch (e) {
      print('❌ Error creating group conversation: $e');
      print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Get conversation details
  Future<Conversation? > getConversationById(String conversationId) async {
    try {
      final conv = await client
          .from(SupabaseConfig.conversationsTable)
          .select()
          .eq('id', conversationId)
          .single();

      return Conversation.fromJson(conv);
    } catch (e) {
      print('Error fetching conversation: $e');
      return null;
    }
  }

  // ============================================
  // MESSAGES
  // ============================================

  /// Get messages for conversation with pagination
  Future<List<Message>> getMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final messages = await client
          .from(SupabaseConfig.messagesTable)
          .select()
          .eq('conversation_id', conversationId)
          . eq('is_deleted', false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Get sender info for each message
      List<Message> result = [];
      for (var msg in messages) {
        final sender = await client
            . from('users')
            .select('full_name, avatar_url')
            .eq('id', msg['sender_id'])
            .maybeSingle();

        msg['sender_name'] = sender? ['full_name'] ?? 'Unknown';
        msg['sender_avatar_url'] = sender?['avatar_url'];

        result.add(Message. fromJson(msg));
      }

      return result. reversed.toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  /// Send text message
  Future<Message?> sendMessage(
    String conversationId,
    String senderId,
    String content,
  ) async {
    try {
      final message = await client
          .from(SupabaseConfig.messagesTable)
          .insert({
            'conversation_id': conversationId,
            'sender_id': senderId,
            'content': content,
            'type': 'text',
            'is_system_message': false,
            'read_by': [senderId], // Sender sudah "baca" pesan sendiri
            'delivered_to': [], // Belum terkirim ke siapa-siapa
          })
          . select()
          .single();

      // Update conversation last_message_at
      await client
          .from(SupabaseConfig.conversationsTable)
          .update({
            'last_message_at': DateTime.now().toIso8601String(),
            'last_message_content': content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversationId);

      // Get sender info
      final sender = await client
          .from('users')
          .select('full_name, avatar_url')
          .eq('id', senderId)
          .single();

      message['sender_name'] = sender['full_name'];
      message['sender_avatar_url'] = sender['avatar_url'];

      return Message.fromJson(message);
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  /// Mark message as delivered to user (NEW)
  Future<void> markMessageDelivered(String messageId, String userId) async {
    try {
      // Get current delivered_to list
      final message = await client
          .from(SupabaseConfig.messagesTable)
          .select('delivered_to')
          .eq('id', messageId)
          .single();

      List<String> deliveredTo = [];
      if (message['delivered_to'] != null) {
        deliveredTo = List<String>.from(message['delivered_to']);
      }

      // Add userId if not already in list
      if (!deliveredTo. contains(userId)) {
        deliveredTo.add(userId);

        await client
            .from(SupabaseConfig.messagesTable)
            .update({'delivered_to': deliveredTo})
            .eq('id', messageId);

        print('✅ Message $messageId marked as delivered to $userId');
      }
    } catch (e) {
      print('⚠️ Error marking message as delivered: $e');
    }
  }

  /// Mark message as read by user (NEW)
  Future<void> markMessageRead(String messageId, String userId) async {
    try {
      // Get current read_by list
      final message = await client
          .from(SupabaseConfig.messagesTable)
          . select('read_by, delivered_to')
          .eq('id', messageId)
          .single();

      List<String> readBy = [];
      List<String> deliveredTo = [];

      if (message['read_by'] != null) {
        readBy = List<String>.from(message['read_by']);
      }
      if (message['delivered_to'] != null) {
        deliveredTo = List<String>.from(message['delivered_to']);
      }

      // Add userId to both lists if not already there
      bool needsUpdate = false;

      if (!readBy.contains(userId)) {
        readBy. add(userId);
        needsUpdate = true;
      }

      if (!deliveredTo.contains(userId)) {
        deliveredTo.add(userId);
        needsUpdate = true;
      }

      if (needsUpdate) {
        await client
            .from(SupabaseConfig.messagesTable)
            .update({
              'read_by': readBy,
              'delivered_to': deliveredTo,
            })
            .eq('id', messageId);

        print('✅ Message $messageId marked as read by $userId');
      }
    } catch (e) {
      print('⚠️ Error marking message as read: $e');
    }
  }

  /// Mark all messages in conversation as read (NEW)
  Future<void> markAllMessagesRead(String conversationId, String userId) async {
    try {
      // Get all unread messages
      final messages = await client
          .from(SupabaseConfig.messagesTable)
          .select('id, read_by, delivered_to')
          .eq('conversation_id', conversationId)
          . neq('sender_id', userId); // Exclude own messages

      for (var message in messages) {
        List<String> readBy = [];
        if (message['read_by'] != null) {
          readBy = List<String>.from(message['read_by']);
        }

        // Only update if not already read
        if (!readBy.contains(userId)) {
          await markMessageRead(message['id'], userId);
        }
      }

      print('✅ All messages in $conversationId marked as read by $userId');
    } catch (e) {
      print('⚠️ Error marking all messages as read: $e');
    }
  }

  /// Check if user is online (NEW)
  Future<bool> isUserOnline(String userId) async {
    try {
      final user = await client
          . from('users')
          .select('is_online, last_seen_at')
          .eq('id', userId)
          .maybeSingle();

      if (user == null) return false;

      // Consider online if is_online=true or last_seen < 5 minutes ago
      if (user['is_online'] == true) return true;

      if (user['last_seen_at'] != null) {
        final lastSeen = DateTime.parse(user['last_seen_at']);
        final diff = DateTime.now().difference(lastSeen);
        return diff. inMinutes < 5;
      }

      return false;
    } catch (e) {
      print('⚠️ Error checking user online status: $e');
      return false;
    }
  }

  /// Update user online status (NEW)
  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await client
          .from('users')
          .update({
            'is_online': isOnline,
            'last_seen_at': DateTime.now().toIso8601String(),
          })
          . eq('id', userId);

      print('🟢 Updated online status for $userId: $isOnline');
    } catch (e) {
      print('⚠️ Error updating online status: $e');
    }
  }

  /// Mark conversation as read
  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      await client
          .from(SupabaseConfig.conversationParticipantsTable)
          .update({'last_read_at': DateTime. now().toIso8601String()})
          .eq('conversation_id', conversationId)
          .eq('user_id', userId);
    } catch (e) {
      print('⚠️ Error marking as read: $e');
    }
  }

  // ============================================
  // REALTIME SUBSCRIPTIONS
  // ============================================

  /// Subscribe to new messages in conversation
  RealtimeChannel subscribeToMessages(
    String conversationId,
    Function(Message) onNewMessage,
    Function(Message) onMessageUpdated, // NEW: callback untuk update
  ) {
    final channel = client
        .channel('messages:$conversationId')
        // Listen to INSERT (new messages)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConfig.messagesTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) async {
            final newMessage = payload.newRecord;
            
            // Get sender info
            final sender = await client
                .from('users')
                .select('full_name, avatar_url')
                .eq('id', newMessage['sender_id'])
                .maybeSingle();

            newMessage['sender_name'] = sender? ['full_name'] ?? 'Unknown';
            newMessage['sender_avatar_url'] = sender?['avatar_url'];

            onNewMessage(Message. fromJson(newMessage));
          },
        )
        // NEW: Listen to UPDATE (read receipts, delivered status)
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: SupabaseConfig. messagesTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) async {
            final updatedMessage = payload. newRecord;
            
            // Get sender info
            final sender = await client
                .from('users')
                .select('full_name, avatar_url')
                .eq('id', updatedMessage['sender_id'])
                . maybeSingle();

            updatedMessage['sender_name'] = sender?['full_name'] ??  'Unknown';
            updatedMessage['sender_avatar_url'] = sender?['avatar_url'];

            print('🔔 Message updated (read receipt): ${updatedMessage['id']}');
            onMessageUpdated(Message.fromJson(updatedMessage));
          },
        )
        . subscribe();

    return channel;
  }

  /// Subscribe to conversation list updates
  RealtimeChannel subscribeToConversationList(
    String userId,
    Function() onUpdate,
  ) {
    final channel = client
        .channel('conversations_list:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseConfig.conversationsTable,
          callback: (payload) {
            print('🔔 Conversation list changed, reloading...');
            onUpdate();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseConfig.messagesTable,
          callback: (payload) {
            print('🔔 New message, reloading conversation list...');
            onUpdate();
          },
        )
        .subscribe();

    return channel;
  }

  /// Unsubscribe from channel
  void unsubscribe(RealtimeChannel channel) {
    client.removeChannel(channel);
  }
}
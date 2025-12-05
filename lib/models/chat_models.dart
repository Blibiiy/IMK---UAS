import 'package:flutter/foundation.dart';

enum ConversationType { private, group }

enum MessageType { text, image, file }

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String?  senderAvatarUrl;
  final String content;
  final MessageType type;
  final String? fileUrl;
  final DateTime createdAt;
  final bool isDeleted;
  final bool isSystemMessage;
  final List<String> readBy;
  final List<String> deliveredTo;

  Message({
    required this. id,
    required this.conversationId,
    required this. senderId,
    required this. senderName,
    this. senderAvatarUrl,
    required this.content,
    required this.type,
    this.fileUrl,
    required this.createdAt,
    this.isDeleted = false,
    this.isSystemMessage = false,
    this.readBy = const [],
    this.deliveredTo = const [],
  });

  MessageStatus getStatus(String currentUserId, bool isRecipientOnline) {
    if (senderId != currentUserId) return MessageStatus.read;
    if (readBy.any((id) => id != currentUserId)) {
      return MessageStatus.read;
    }
    if (deliveredTo.any((id) => id != currentUserId)) {
      return MessageStatus.delivered;
    }
    return MessageStatus.sent;
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    MessageType messageType = MessageType.text;
    if (json['type'] == 'image') {
      messageType = MessageType.image;
    } else if (json['type'] == 'file') {
      messageType = MessageType.file;
    }

    List<String> readByList = [];
    List<String> deliveredToList = [];

    if (json['read_by'] != null) {
      if (json['read_by'] is List) {
        readByList = List<String>.from(json['read_by']);
      }
    }

    if (json['delivered_to'] != null) {
      if (json['delivered_to'] is List) {
        deliveredToList = List<String>.from(json['delivered_to']);
      }
    }

    // FIX: Convert UTC to local time
    DateTime createdAtLocal = DateTime.now();
    if (json['created_at'] != null) {
      try {
        // Parse as UTC then convert to local
        final utcTime = DateTime.parse(json['created_at']);
        createdAtLocal = utcTime. toLocal();
        
        print('🕐 UTC: $utcTime → Local: $createdAtLocal');
      } catch (e) {
        print('⚠️ Error parsing created_at: $e');
      }
    }

    return Message(
      id: json['id']. toString(),
      conversationId: json['conversation_id'].toString(),
      senderId: json['sender_id'].toString(),
      senderName: json['sender_name'] ?? 'Unknown',
      senderAvatarUrl: json['sender_avatar_url'],
      content: json['content'] ?? '',
      type: messageType,
      fileUrl: json['file_url'],
      createdAt: createdAtLocal, // FIX: Use local time
      isDeleted: json['is_deleted'] ?? false,
      isSystemMessage: json['is_system_message'] ??  false,
      readBy: readByList,
      deliveredTo: deliveredToList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar_url': senderAvatarUrl,
      'content': content,
      'type': type.toString(). split('.').last,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
      'is_deleted': isDeleted,
      'is_system_message': isSystemMessage,
      'read_by': readBy,
      'delivered_to': deliveredTo,
    };
  }
}

class Conversation {
  final String id;
  final ConversationType type;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime?  lastMessageAt;
  final String? lastMessageContent;
  final int unreadCount;
  final List<String> participantIds;

  Conversation({
    required this.id,
    required this.type,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessageContent,
    this.unreadCount = 0,
    this.participantIds = const [],
  });

  factory Conversation. fromJson(Map<String, dynamic> json) {
    ConversationType convType = json['type'] == 'group'
        ? ConversationType.group
        : ConversationType.private;

    // FIX: Convert UTC to local time for conversations
    DateTime createdAtLocal = DateTime.now();
    if (json['created_at'] != null) {
      try {
        final utcTime = DateTime.parse(json['created_at']);
        createdAtLocal = utcTime.toLocal();
      } catch (e) {
        print('⚠️ Error parsing conversation created_at: $e');
      }
    }

    DateTime?  lastMessageAtLocal;
    if (json['last_message_at'] != null) {
      try {
        final utcTime = DateTime.parse(json['last_message_at']);
        lastMessageAtLocal = utcTime.toLocal();
      } catch (e) {
        print('⚠️ Error parsing last_message_at: $e');
      }
    }

    return Conversation(
      id: json['id'].toString(),
      type: convType,
      name: json['name'] ?? 'Unknown',
      avatarUrl: json['avatar_url'],
      createdAt: createdAtLocal, // FIX: Use local time
      lastMessageAt: lastMessageAtLocal, // FIX: Use local time
      lastMessageContent: json['last_message_content'],
      unreadCount: json['unread_count'] ?? 0,
      participantIds: json['participant_ids'] != null
          ?  List<String>.from(json['participant_ids'])
          : [],
    );
  }

  String getTimestamp() {
    if (lastMessageAt == null) return '';
    
    // FIX: Use local time for calculation
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff. inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';

    // Format: DD/MM
    return '${lastMessageAt!.day}/${lastMessageAt!.month}';
  }
}
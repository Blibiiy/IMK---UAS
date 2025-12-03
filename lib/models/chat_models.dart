import 'package:flutter/foundation.dart';

enum ConversationType { private, group }

enum MessageType { text, image, file }

// NEW: Message status enum
enum MessageStatus {
  sending,    // Sedang dikirim
  sent,       // Terkirim (centang 1)
  delivered,  // Terkirim ke user online (centang 2 abu)
  read,       // Sudah dibaca (centang 2 biru)
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
  final bool isSystemMessage; // NEW
  final List<String> readBy; // NEW: List user IDs yang sudah baca
  final List<String> deliveredTo; // NEW: List user IDs yang sudah terima

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

  // NEW: Get message status untuk sender
  MessageStatus getStatus(String currentUserId, bool isRecipientOnline) {
    // Jika bukan pesan sendiri, return read
    if (senderId != currentUserId) return MessageStatus.read;

    // Jika sudah dibaca oleh orang lain
    if (readBy.any((id) => id != currentUserId)) {
      return MessageStatus.read;
    }

    // Jika sudah terkirim ke user online
    if (deliveredTo.any((id) => id != currentUserId)) {
      return MessageStatus.delivered;
    }

    // Default: sudah terkirim
    return MessageStatus.sent;
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    MessageType messageType = MessageType.text;
    if (json['type'] == 'image') {
      messageType = MessageType.image;
    } else if (json['type'] == 'file') {
      messageType = MessageType.file;
    }

    // Parse readBy and deliveredTo from jsonb
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

    return Message(
      id: json['id']. toString(),
      conversationId: json['conversation_id'].toString(),
      senderId: json['sender_id'].toString(),
      senderName: json['sender_name'] ?? 'Unknown',
      senderAvatarUrl: json['sender_avatar_url'],
      content: json['content'] ?? '',
      type: messageType,
      fileUrl: json['file_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isDeleted: json['is_deleted'] ??  false,
      isSystemMessage: json['is_system_message'] ?? false,
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

    return Conversation(
      id: json['id'].toString(),
      type: convType,
      name: json['name'] ?? 'Unknown',
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      lastMessageContent: json['last_message_content'],
      unreadCount: json['unread_count'] ?? 0,
      participantIds: json['participant_ids'] != null
          ? List<String>.from(json['participant_ids'])
          : [],
    );
  }

  String getTimestamp() {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff. inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';

    return '${lastMessageAt!.day}/${lastMessageAt!.month}';
  }
}
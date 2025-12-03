import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';
import '../config/supabase_config.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<Conversation> _conversations = [];
  Map<String, List<Message>> _messagesCache = {};
  Map<String, RealtimeChannel> _subscriptions = {};
  RealtimeChannel?  _conversationListSubscription;

  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  String? _errorMessage;
  String? _currentUserId;

  List<Conversation> get conversations => _conversations;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  String?  get errorMessage => _errorMessage;

  List<Message> getMessages(String conversationId) {
    return _messagesCache[conversationId] ?? [];
  }

  // ============================================
  // CONVERSATIONS
  // ============================================

  /// Load all conversations for current user
  Future<void> loadConversations(String userId) async {
    _currentUserId = userId;
    _isLoadingConversations = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _conversations = await _chatService.getMyConversations(userId);
      _subscribeToConversationList(userId);
    } catch (e) {
      _errorMessage = 'Gagal memuat conversations: $e';
      print(_errorMessage);
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  void _subscribeToConversationList(String userId) {
    if (_conversationListSubscription != null) {
      _chatService.unsubscribe(_conversationListSubscription!);
    }

    _conversationListSubscription = _chatService. subscribeToConversationList(
      userId,
      () async {
        if (_currentUserId != null) {
          final updatedConversations = await _chatService.getMyConversations(_currentUserId!);
          _conversations = updatedConversations;
          notifyListeners();
        }
      },
    );
  }

  Future<String?> getOrCreatePrivateChat(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      final conversationId = await _chatService. getOrCreatePrivateConversation(
        currentUserId,
        otherUserId,
      );
      
      if (conversationId != null) {
        await loadConversations(currentUserId);
      }
      
      return conversationId;
    } catch (e) {
      _errorMessage = 'Gagal membuat chat: $e';
      print(_errorMessage);
      return null;
    }
  }

  Future<String?> createProjectGroupChat(
    String projectId,
    String projectTitle,
    List<String> memberIds,
  ) async {
    try {
      final conversationId = await _chatService.createProjectGroupConversation(
        projectId,
        projectTitle,
        memberIds,
      );
      
      if (conversationId != null && memberIds.isNotEmpty) {
        await loadConversations(memberIds.first);
      }
      
      return conversationId;
    } catch (e) {
      _errorMessage = 'Gagal membuat grup chat: $e';
      print(_errorMessage);
      return null;
    }
  }

  Future<void> addMemberToGroupChat(
    String conversationId,
    String userId,
  ) async {
    try {
      await Supabase.instance.client
          .from(SupabaseConfig.conversationParticipantsTable)
          .insert({
            'conversation_id': conversationId,
            'user_id': userId,
          });

      print('✅ User $userId added to group chat $conversationId');
      await loadConversations(userId);
    } catch (e) {
      print('Error adding member to group chat: $e');
      rethrow;
    }
  }

  // ============================================
  // MESSAGES
  // ============================================

  Future<void> loadMessages(String conversationId) async {
    _isLoadingMessages = true;
    notifyListeners();

    try {
      final messages = await _chatService.getMessages(conversationId);
      _messagesCache[conversationId] = messages;
    } catch (e) {
      _errorMessage = 'Gagal memuat messages: $e';
      print(_errorMessage);
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  /// Send message (FIXED: prevent duplicate)
  Future<void> sendMessage(
    String conversationId,
    String senderId,
    String content,
  ) async {
    try {
      final message = await _chatService.sendMessage(
        conversationId,
        senderId,
        content,
      );

      if (message != null) {
        // FIX: Jangan add ke cache di sini
        // Biarkan realtime subscription yang handle
        // Ini mencegah duplicate message
        
        print('📤 Message sent: ${message.id}');
        
        // Hanya update conversation list (move to top)
        final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
        if (convIndex != -1) {
          final conv = _conversations. removeAt(convIndex);
          _conversations.insert(0, conv);
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = 'Gagal mengirim pesan: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      await _chatService.markAsRead(conversationId, userId);
      
      final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (convIndex != -1) {
        final oldConv = _conversations[convIndex];
        _conversations[convIndex] = Conversation(
          id: oldConv.id,
          type: oldConv.type,
          name: oldConv.name,
          avatarUrl: oldConv.avatarUrl,
          createdAt: oldConv.createdAt,
          lastMessageAt: oldConv.lastMessageAt,
          lastMessageContent: oldConv.lastMessageContent,
          unreadCount: 0,
          participantIds: oldConv.participantIds,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // ============================================
  // READ RECEIPTS
  // ============================================

  Future<void> markMessageDelivered(String messageId, String userId) async {
    try {
      await _chatService.markMessageDelivered(messageId, userId);
      // Realtime akan handle update UI
    } catch (e) {
      print('Error marking message as delivered: $e');
    }
  }

  Future<void> markMessageRead(String messageId, String userId) async {
    try {
      await _chatService.markMessageRead(messageId, userId);
      // Realtime akan handle update UI
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  /// Helper method to update message in cache (digunakan oleh realtime)
  void _updateMessageInCache(String messageId, Message updatedMessage) {
    for (var conversationId in _messagesCache. keys) {
      final messages = _messagesCache[conversationId]! ;
      final index = messages.indexWhere((m) => m.id == messageId);
      
      if (index != -1) {
        _messagesCache[conversationId]![index] = updatedMessage;
        print('✅ Message updated in cache: $messageId');
        notifyListeners();
        break;
      }
    }
  }

  // ============================================
  // REALTIME SUBSCRIPTIONS
  // ============================================

  /// Subscribe to new messages (UPDATED: with onMessageUpdated callback)
  void subscribeToMessages(String conversationId) {
    if (_subscriptions. containsKey(conversationId)) return;

    final channel = _chatService.subscribeToMessages(
      conversationId,
      // onNewMessage callback
      (newMessage) {
        _messagesCache[conversationId] ??= [];
        
        // Check if message already exists
        final exists = _messagesCache[conversationId]! 
            .any((m) => m.id == newMessage.id);
        
        if (!exists) {
          _messagesCache[conversationId]!.add(newMessage);
          print('📩 New message received: ${newMessage.id}');
          notifyListeners();
        } else {
          print('⚠️ Duplicate message prevented: ${newMessage.id}');
        }
      },
      // onMessageUpdated callback (NEW)
      (updatedMessage) {
        _updateMessageInCache(updatedMessage.id, updatedMessage);
      },
    );

    _subscriptions[conversationId] = channel;
  }

  void unsubscribeFromMessages(String conversationId) {
    if (_subscriptions.containsKey(conversationId)) {
      _chatService.unsubscribe(_subscriptions[conversationId]! );
      _subscriptions.remove(conversationId);
    }
  }

  void unsubscribeAll() {
    for (var channel in _subscriptions.values) {
      _chatService.unsubscribe(channel);
    }
    _subscriptions.clear();

    if (_conversationListSubscription != null) {
      _chatService. unsubscribe(_conversationListSubscription!);
      _conversationListSubscription = null;
    }
  }

  @override
  void dispose() {
    unsubscribeAll();
    super.dispose();
  }
}
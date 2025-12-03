import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
      _subscribeToMessages();
      _markAsRead();
      _updateOnlineStatus(true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final userId = context.read<UserProvider>().currentUser?. id;
    if (userId == null) return;

    if (state == AppLifecycleState.resumed) {
      _updateOnlineStatus(true);
      _markAsRead();
    } else if (state == AppLifecycleState.paused) {
      _updateOnlineStatus(false);
    }
  }

  void _updateOnlineStatus(bool isOnline) {
    final userId = context.read<UserProvider>().currentUser?.id;
    if (userId != null) {
      _chatService.updateUserOnlineStatus(userId, isOnline);
    }
  }

  void _loadMessages() {
    context.read<ChatProvider>().loadMessages(widget.conversation.id);
  }

  void _subscribeToMessages() {
    context.read<ChatProvider>().subscribeToMessages(widget.conversation. id);
  }

  void _markAsRead() {
    final userId = context.read<UserProvider>().currentUser?.id;
    if (userId != null) {
      context.read<ChatProvider>().markAsRead(widget. conversation.id, userId);
      // Mark all messages as read
      _chatService.markAllMessagesRead(widget.conversation.id, userId);
    }
  }

   void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final userId = context.read<UserProvider>().currentUser?.id;
    if (userId == null) return;

    // FIX: Tidak perlu add manual ke cache
    // Biarkan realtime subscription yang handle
    context.read<ChatProvider>().sendMessage(
          widget.conversation.id,
          userId,
          content,
        );

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateOnlineStatus(false);
    context.read<ChatProvider>().unsubscribeFromMessages(widget.conversation.id);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentUserId = context.read<UserProvider>().currentUser?.id ??  '';
    final messages = context.watch<ChatProvider>().getMessages(widget.conversation. id);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: ChatDetailAppBar(conversation: widget.conversation),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada pesan',
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                    itemCount: messages. length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == currentUserId;

                      // Show date divider if new day
                      bool showDateDivider = false;
                      if (index == 0) {
                        showDateDivider = true;
                      } else {
                        final prevMessage = messages[index - 1];
                        if (! _isSameDay(prevMessage.createdAt, message. createdAt)) {
                          showDateDivider = true;
                        }
                      }

                      // Mark message as delivered when viewed
                      if (! isMe && ! message.deliveredTo.contains(currentUserId)) {
                        _chatService.markMessageDelivered(message.id, currentUserId);
                      }

                      return Column(
                        children: [
                          if (showDateDivider) _buildDateDivider(message.createdAt, cs),
                          
                          // System message (notifikasi)
                          if (message.isSystemMessage)
                            _buildSystemMessage(message, cs)
                          else
                            ChatBubble(
                              message: message,
                              isMe: isMe,
                              currentUserId: currentUserId,
                              showSenderName: widget.conversation.type == ConversationType.group && !isMe,
                            ),
                        ],
                      );
                    },
                  ),
          ),
          // Chat Input Bar
          ChatInputBar(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildDateDivider(DateTime date, ColorScheme cs) {
    final now = DateTime.now();
    String dateText;

    if (_isSameDay(date, now)) {
      dateText = 'Hari Ini';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      dateText = 'Kemarin';
    } else {
      dateText = DateFormat('dd MMMM yyyy'). format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: cs. surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dateText,
          style: TextStyle(fontSize: 12, color: cs. onSurface),
        ),
      ),
    );
  }

  // NEW: System message widget
  Widget _buildSystemMessage(Message message, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: cs.secondaryContainer. withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 16, color: cs.onSecondaryContainer),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs. onSecondaryContainer,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Chat Detail AppBar Component
class ChatDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Conversation conversation;

  const ChatDetailAppBar({super. key, required this.conversation});

  @override
  Size get preferredSize => const Size. fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: cs.surfaceVariant,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset('assets/logos/back. svg', width: 24, height: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // Avatar or Group Icon
          conversation.type == ConversationType.group
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.primary, width: 2),
                  ),
                  child: Icon(Icons.group_outlined, size: 20, color: cs. primary),
                )
              : CircleAvatar(
                  radius: 20,
                  backgroundImage: conversation.avatarUrl != null
                      ? NetworkImage(conversation.avatarUrl!)
                      : null,
                  backgroundColor: cs.primaryContainer,
                  child: conversation.avatarUrl == null
                      ?  Icon(Icons.person, size: 20, color: cs.primary)
                      : null,
                ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  conversation.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs. onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (conversation.type == ConversationType.group)
                  Text(
                    'Grup',
                    style: TextStyle(fontSize: 12, color: cs. onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: cs.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }
}

// UPDATED: Chat Bubble with read receipts
class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String currentUserId;
  final bool showSenderName;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.currentUserId,
    this.showSenderName = false,
  });

  Widget _buildReadReceipt(ColorScheme cs) {
    final status = message.getStatus(currentUserId, true);

    switch (status) {
      case MessageStatus.sent:
        // Centang 1 (abu-abu)
        return Icon(Icons.check, size: 16, color: cs.onSurfaceVariant);
      
      case MessageStatus.delivered:
        // Centang 2 (abu-abu)
        return Icon(Icons.done_all, size: 16, color: cs.onSurfaceVariant);
      
      case MessageStatus.read:
        // Centang 2 (biru)
        return const Icon(Icons.done_all, size: 16, color: Color(0xFF2E5AAC));
      
      default:
        return const SizedBox. shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender name for group chats
          if (showSenderName)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
              child: Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ),
          // Message bubble
          Align(
            alignment: isMe ?  Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isMe ? cs.primaryContainer : cs.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 16 : 4),
                  topRight: Radius.circular(isMe ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(fontSize: 14, color: cs.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message. createdAt),
                        style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _buildReadReceipt(cs),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Chat Input Bar Component
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this. controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        border: Border(top: BorderSide(color: cs.outline, width: 1)),
      ),
      child: Row(
        children: [
          // Plus Button (untuk attachment - future feature)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surface,
              shape: BoxShape. circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, size: 24),
              onPressed: () {
                // TODO: Handle attachment
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur attachment segera hadir')),
                );
              },
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 12),
          // Text Field
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Tulis Pesan...',
                hintStyle: TextStyle(fontSize: 14, color: cs. onSurfaceVariant),
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 12),
          // Send Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, size: 20, color: cs.onPrimary),
              onPressed: onSend,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
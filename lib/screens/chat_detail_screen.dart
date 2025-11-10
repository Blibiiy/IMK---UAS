import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'chat_list_screen.dart';

class Message {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String timestamp;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });
}

class ChatDetailScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String myId = 'my_dummy_id';

  // Dummy messages
  final List<Message> _messages = [
    Message(
      id: '1',
      text: 'Lorem Ipsum',
      senderId: 'user_1',
      senderName: 'Aidi',
      timestamp: '03:15',
    ),
    Message(
      id: '2',
      text: 'Lorem Ipsum',
      senderId: 'user_2',
      senderName: 'Isra',
      timestamp: '03:15',
    ),
    Message(
      id: '3',
      text: 'Lorem Ipsum',
      senderId: 'my_dummy_id',
      senderName: 'Me',
      timestamp: '03:15',
    ),
    Message(
      id: '4',
      text: 'Lorem Ipsum',
      senderId: 'my_dummy_id',
      senderName: 'Me',
      timestamp: '03:15',
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ChatDetailAppBar(conversation: widget.conversation),
      body: Column(
        children: [
          // Date Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Hari Ini',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ),
          // Messages List
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return ChatBubble(
                  message: message,
                  conversationType: widget.conversation.type,
                  myId: myId,
                );
              },
            ),
          ),
          // Chat Input Bar
          ChatInputBar(
            controller: _messageController,
            onSend: () {
              // Handle send message
              if (_messageController.text.trim().isNotEmpty) {
                // Add message logic here
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

// Chat Detail AppBar Component
class ChatDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Conversation conversation;

  const ChatDetailAppBar({super.key, required this.conversation});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFE0E0E0),
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset('assets/logos/back.svg', width: 24, height: 24),
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
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(Icons.group_outlined, size: 20),
                )
              : CircleAvatar(
                  radius: 20,
                  backgroundImage: conversation.avatarUrl != null
                      ? NetworkImage(conversation.avatarUrl!)
                      : null,
                  backgroundColor: Colors.white,
                ),
          const SizedBox(width: 12),
          // Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  conversation.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  conversation.type == ConversationType.group
                      ? '3 Online'
                      : 'Online',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {
            // Handle menu
          },
        ),
      ],
    );
  }
}

// Chat Bubble Component
class ChatBubble extends StatelessWidget {
  final Message message;
  final ConversationType conversationType;
  final String myId;

  const ChatBubble({
    super.key,
    required this.message,
    required this.conversationType,
    required this.myId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.senderId == myId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Sender name for group chats (only if not me)
          if (conversationType == ConversationType.group && !isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
              child: Text(
                message.senderName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          // Message bubble
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFD0D0D0) : const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 16 : 4),
                  topRight: Radius.circular(isMe ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      message.text,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timestamp,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all,
                          size: 14,
                          color: Colors.black54,
                        ),
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
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        border: Border(top: BorderSide(color: Color(0xFFD0D0D0), width: 1)),
      ),
      child: Row(
        children: [
          // Plus Button
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, size: 24),
              onPressed: () {
                // Handle attachment
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
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
        ],
      ),
    );
  }
}

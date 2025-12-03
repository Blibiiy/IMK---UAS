import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chat_models.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super. initState();
    // Load conversations when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserProvider>().currentUser?.id;
      if (userId != null) {
        context.read<ChatProvider>().loadConversations(userId);
      }
    });
  }

  List<Conversation> _filterConversations(List<Conversation> conversations) {
    if (_selectedFilter == 'Semua') return conversations;
    if (_selectedFilter == 'Grup') {
      return conversations.where((c) => c.type == ConversationType.group).toList();
    }
    if (_selectedFilter == 'Private') {
      return conversations.where((c) => c.type == ConversationType.private).toList();
    }
    return conversations;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final chatProvider = context.watch<ChatProvider>();
    final conversations = _filterConversations(chatProvider.conversations);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/logos/back.svg',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chat',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Filter Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(value: 'Semua', label: Text('Semua')),
                  ButtonSegment<String>(value: 'Grup', label: Text('Grup')),
                  ButtonSegment<String>(value: 'Private', label: Text('Private')),
                ],
                selected: {_selectedFilter},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedFilter = newSelection.first;
                  });
                },
              ),
            ),
            // Conversations List
            Expanded(
              child: chatProvider.isLoadingConversations
                  ?  const Center(child: CircularProgressIndicator())
                  : conversations.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada chat',
                            style: TextStyle(
                              fontSize: 16,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return ConversationListTile(
                              conversation: conversation,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailScreen(
                                      conversation: conversation,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// Conversation List Tile Component
// ...  (import tetap sama)

// UPDATED: ConversationListTile dengan unread counter
// ...  (import tetap sama)

// UPDATED: ConversationListTile dengan unread counter
class ConversationListTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationListTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar or Group Icon
            conversation.type == ConversationType.group
                ? Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.primary, width: 2),
                    ),
                    child: Icon(
                      Icons.group_outlined,
                      size: 24,
                      color: cs.primary,
                    ),
                  )
                : CircleAvatar(
                    radius: 25,
                    backgroundImage: conversation.avatarUrl != null
                        ?  NetworkImage(conversation.avatarUrl!)
                        : null,
                    backgroundColor: cs.primaryContainer,
                    child: conversation.avatarUrl == null
                        ?  Icon(Icons.person, color: cs.primary)
                        : null,
                  ),
            const SizedBox(width: 16),
            // Name and Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cs. onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        conversation.getTimestamp(),
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessageContent ??  'Belum ada pesan',
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // NEW: Unread counter badge
                      if (conversation. unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          child: Center(
                            child: Text(
                              conversation.unreadCount > 99
                                  ? '99+'
                                  : '${conversation.unreadCount}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: cs.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
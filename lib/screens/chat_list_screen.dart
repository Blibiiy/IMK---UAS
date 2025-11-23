import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'chat_detail_screen.dart';

enum ConversationType { private, group }

enum FilterType { semua, grup, private }

class Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final String timestamp;
  final String? avatarUrl;
  final ConversationType type;

  Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    this.avatarUrl,
    required this.type,
  });
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  FilterType _currentFilter = FilterType.semua;

  final List<Conversation> _conversations = [
    Conversation(
      id: '1',
      name: 'ISRA',
      lastMessage: 'Lorem Ipsum ...',
      timestamp: '03:00',
      avatarUrl: 'https://placehold.co/100x100/E0E0E0/E0E0E0',
      type: ConversationType.private,
    ),
    Conversation(
      id: '2',
      name: 'Aldi',
      lastMessage: 'Lorem Ipsum ...',
      timestamp: '03:00',
      avatarUrl: 'https://placehold.co/100x100/E0E0E0/E0E0E0',
      type: ConversationType.private,
    ),
    Conversation(
      id: '3',
      name: 'Project Kampus',
      lastMessage: 'Lorem Ipsum ...',
      timestamp: '03:00',
      type: ConversationType.group,
    ),
    Conversation(
      id: '4',
      name: 'Project 1',
      lastMessage: 'Lorem Ipsum ...',
      timestamp: '03:00',
      type: ConversationType.group,
    ),
    Conversation(
      id: '5',
      name: 'Project 3',
      lastMessage: 'Lorem Ipsum ...',
      timestamp: '03:00',
      type: ConversationType.group,
    ),
  ];

  List<Conversation> get _filteredConversations {
    switch (_currentFilter) {
      case FilterType.grup:
        return _conversations
            .where((c) => c.type == ConversationType.group)
            .toList();
      case FilterType.private:
        return _conversations
            .where((c) => c.type == ConversationType.private)
            .toList();
      case FilterType.semua:
        return _conversations;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16,
              ),
              child: SegmentedButton<FilterType>(
                segments: const [
                  ButtonSegment<FilterType>(
                    value: FilterType.semua,
                    label: Text('Semua'),
                  ),
                  ButtonSegment<FilterType>(
                    value: FilterType.grup,
                    label: Text('Grup'),
                  ),
                  ButtonSegment<FilterType>(
                    value: FilterType.private,
                    label: Text('Private'),
                  ),
                ],
                selected: {_currentFilter},
                onSelectionChanged: (Set<FilterType> newSelection) {
                  setState(() {
                    _currentFilter = newSelection.first;
                  });
                },
              ),
            ),
            // Conversations List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredConversations.length,
                itemBuilder: (context, index) {
                  final conversation = _filteredConversations[index];
                  return ConversationListTile(
                    conversation: conversation,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatDetailScreen(conversation: conversation),
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
                      color: cs.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.outline, width: 2),
                    ),
                    child: Icon(
                      Icons.group_outlined,
                      size: 24,
                      color: cs.onSurface,
                    ),
                  )
                : CircleAvatar(
                    radius: 25,
                    backgroundImage: conversation.avatarUrl != null
                        ? NetworkImage(conversation.avatarUrl!)
                        : null,
                    backgroundColor: cs.surface,
                  ),
            const SizedBox(width: 16),
            // Name and Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage,
                    style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Timestamp
            Text(
              conversation.timestamp,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

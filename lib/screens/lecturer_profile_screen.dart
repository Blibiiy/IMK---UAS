import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/chat_provider.dart'; // NEW
import '../providers/project_provider.dart';
import 'lecturer_home_screen.dart';
import 'chat_list_screen.dart';
import '../theme/app_theme.dart';

class LecturerProfileScreen extends StatefulWidget {
  const LecturerProfileScreen({super.key});

  @override
  State<LecturerProfileScreen> createState() => _LecturerProfileScreenState();
}

class _LecturerProfileScreenState extends State<LecturerProfileScreen> {
  int _currentIndex = 2;

  @override
  void initState() {
    super. initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserProvider>().currentUser?.id;
      if (userId != null) {
        // Load history projects
        context.read<ProjectProvider>().loadProjects();
        // NEW: Load conversations untuk badge
        context.read<ChatProvider>().loadConversations(userId);
      }
    });
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LecturerHomeScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatListScreen()),
      );
    }
  }

  // NEW: Calculate total unread count
  int _getTotalUnreadCount() {
    final conversations = context.watch<ChatProvider>().conversations;
    return conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;
    final projectProvider = context.watch<ProjectProvider>();
    final totalUnread = _getTotalUnreadCount(); // NEW

    // Get lecturer's projects
    final lecturerName = currentUser?.fullName ?? '';
    final lecturerProjects = projectProvider. getProjectsByLecturer(lecturerName);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
              decoration: AppTheme.headerDecoration(cs),
              child: _LecturerHeaderCard(
                name: currentUser?.fullName ?? 'Dosen',
                program: 'Dosen',
                imageUrl:
                    currentUser?.avatarUrl ??
                    'https://placehold.co/100x100/E0E0E0/E0E0E0',
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'History Project',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: lecturerProjects.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'Belum ada project',
                          style: TextStyle(
                            fontSize: 16,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView. builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lecturerProjects.length,
                      itemBuilder: (context, index) {
                        final project = lecturerProjects[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _ProjectHistoryCard(
                            title: project.title,
                            description: project.description,
                            deadline: project.deadline,
                            onDetailTap: () {
                              // Navigate to detail if needed
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  context.read<UserProvider>().logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/logos/logout.svg',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: cs. onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      // NEW: Bottom navbar dengan chat icon + badge
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/logos/homeinactive.svg', width: 28, height: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 28), // FIXED: Consistent size
                if (totalUnread > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/logos/profileactive.svg', width: 28, height: 28),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _LecturerHeaderCard extends StatelessWidget {
  final String name;
  final String program;
  final String imageUrl;

  const _LecturerHeaderCard({
    required this.name,
    required this.program,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white. withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  program,
                  style: TextStyle(fontSize: 14, color: cs. onPrimary. withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectHistoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String deadline;
  final VoidCallback onDetailTap;

  const _ProjectHistoryCard({
    required this.title,
    required this.description,
    required this.deadline,
    required this. onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: cs. onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                deadline,
                style: TextStyle(fontSize: 12, color: cs. onSurfaceVariant),
              ),
              GestureDetector(
                onTap: onDetailTap,
                child: Text(
                  'Detail >>',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cs. primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
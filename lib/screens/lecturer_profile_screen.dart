import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/chat_provider.dart'; // NEW
import '../providers/project_provider.dart';
import 'lecturer_home_screen.dart';
import 'lecturer_project_detail_screen.dart';
import 'chat_list_screen.dart';
import '../theme/app_theme.dart';

class LecturerProfileScreen extends StatefulWidget {
  const LecturerProfileScreen({super.key});

  @override
  State<LecturerProfileScreen> createState() => _LecturerProfileScreenState();
}

class _LecturerProfileScreenState extends State<LecturerProfileScreen> {
  int _currentIndex = 2;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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

  Widget _buildProjectList(List<Project> allProjects, ColorScheme cs) {
    // Hanya tampilkan project yang sudah selesai (Riwayat)
    List<Project> filteredProjects = allProjects
        .where((p) => p.status == ProjectStatus.selesai)
        .toList();

    // Filter berdasarkan search query
    if (_searchQuery.isNotEmpty) {
      filteredProjects = filteredProjects.where((project) {
        return project.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            project.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Empty state
    if (filteredProjects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: cs.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada project yang selesai',
                style: TextStyle(
                  fontSize: 16,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Riwayat project yang sudah selesai akan muncul di sini',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Project list
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredProjects.length,
      itemBuilder: (context, index) {
        final project = filteredProjects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _HistoryProjectCard(
            projectId: project.id,
            title: project.title,
            description: project.description,
            deadline: project.deadline,
            status: project.status,
            memberCount: project.members.length,
          ),
        );
      },
    );
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
    final lecturerProjects = projectProvider.getProjectsByLecturer(
      lecturerName,
    );

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
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Cari project...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: cs.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Project list based on selected tab
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildProjectList(lecturerProjects, cs),
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
                      Icon(Icons.logout, size: 24, color: cs.onSurface),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface,
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
            icon: SvgPicture.asset(
              'assets/logos/homeinactive.svg',
              width: 28,
              height: 28,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 28,
                ), // FIXED: Consistent size
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
            icon: SvgPicture.asset(
              'assets/logos/profileactive.svg',
              width: 28,
              height: 28,
            ),
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
        color: Colors.white.withOpacity(0.08),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryProjectCard extends StatelessWidget {
  final String projectId;
  final String title;
  final String description;
  final String deadline;
  final ProjectStatus status;
  final int memberCount;

  const _HistoryProjectCard({
    required this.projectId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    required this.memberCount,
  });

  String _getStatusText() {
    switch (status) {
      case ProjectStatus.tersedia:
        return 'Pendaftaran';
      case ProjectStatus.diproses:
        return 'Proses';
      case ProjectStatus.diterima:
        return 'Berjalan';
      case ProjectStatus.selesai:
        return 'Selesai';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case ProjectStatus.tersedia:
        return const Color(0xFF2E5AAC);
      case ProjectStatus.diproses:
        return const Color(0xFFF57C00);
      case ProjectStatus.diterima:
        return const Color(0xFF1976D2);
      case ProjectStatus.selesai:
        return const Color(0xFF388E3C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LecturerProjectDetailScreen(projectId: projectId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      deadline,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      '$memberCount Anggota',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

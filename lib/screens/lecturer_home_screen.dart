import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/project_provider.dart';
import '../providers/user_provider.dart';
import '../providers/chat_provider.dart'; // ONLY NEW IMPORT
import 'lecturer_project_detail_screen.dart';
import 'lecturer_profile_screen.dart';
import 'chat_list_screen.dart';
import 'lecturer_add_project_screen.dart';
import '../theme/app_theme.dart';

class LecturerHomeScreen extends StatefulWidget {
  const LecturerHomeScreen({super.key});

  @override
  State<LecturerHomeScreen> createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  int _currentIndex = 0;
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects();

      // ONLY NEW: Load conversations untuk badge counter
      final userId = context.read<UserProvider>().currentUser?.id;
      if (userId != null) {
        context.read<ChatProvider>().loadConversations(userId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;
    if (index == 0) {
      setState(() => _currentIndex = 0);
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatListScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LecturerProfileScreen()),
      );
    }
  }

  void _onAddProject() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LecturerAddProjectScreen()),
    );
  }

  // ONLY NEW METHOD: Calculate total unread count
  int _getTotalUnreadCount() {
    final conversations = context.watch<ChatProvider>().conversations;
    return conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;
    final totalUnread = _getTotalUnreadCount(); // ONLY NEW

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddProject,
        backgroundColor: cs.secondary,
        foregroundColor: cs.onSecondary,
        child: const Icon(Icons.add),
      ),

      // ONLY MODIFIED: Bottom nav with badge
      // ... (kode sebelumnya sama)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/logos/homeactive.svg',
              width: 28,
              height: 28,
            ), // CHANGED: 24 → 28
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 28,
                ), // CHANGED: 24 → 28
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
              'assets/logos/profileinactive.svg',
              width: 28,
              height: 28,
            ), // CHANGED: 24 → 28
            label: 'Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              decoration: AppTheme.headerDecoration(cs),
              child: _LecturerHeaderCard(
                name: currentUser?.fullName ?? 'Dosen',
                program: currentUser?.role == 'dosen'
                    ? 'Dosen'
                    : (currentUser?.program ?? ''),
                imageUrl:
                    currentUser?.avatarUrl ??
                    'https://placehold.co/100x100/E0E0E0/E0E0E0',
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari project...',
                  hintStyle: TextStyle(
                    color: cs.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: cs.onSurfaceVariant,
                    size: 22,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: cs.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Project',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _selectedFilter = value;
                      });
                    },
                    itemBuilder: (BuildContext context) => const [
                      PopupMenuItem<String>(
                        value: 'Semua',
                        child: Text('Semua'),
                      ),
                      PopupMenuItem<String>(
                        value: 'Pendaftaran',
                        child: Text('Pendaftaran'),
                      ),
                      PopupMenuItem<String>(
                        value: 'Proses',
                        child: Text('Proses'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedFilter,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cs.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.filter_list,
                            size: 20,
                            color: cs.onSecondaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Consumer<ProjectProvider>(
                builder: (context, provider, _) {
                  final lecturerName = currentUser?.fullName ?? '';
                  final allProjects = provider.getProjectsByLecturer(
                    lecturerName,
                  );

                  // Exclude finished projects (only show in History)
                  final activeProjects = allProjects
                      .where((p) => p.status != ProjectStatus.selesai)
                      .toList();

                  final filteredProjects = activeProjects.where((project) {
                    String tag;
                    if (project.status == ProjectStatus.tersedia) {
                      tag = 'Pendaftaran';
                    } else {
                      tag = 'Proses';
                    }
                    final statusMatch =
                        _selectedFilter == 'Semua' || tag == _selectedFilter;
                    final titleMatch =
                        _searchQuery.isEmpty ||
                        project.title.toLowerCase().contains(_searchQuery);
                    return statusMatch && titleMatch;
                  }).toList();

                  if (filteredProjects.isEmpty) {
                    String emptyMessage = 'Belum ada proyek';
                    if (_searchQuery.isNotEmpty && _selectedFilter != 'Semua') {
                      emptyMessage =
                          'Tidak ada proyek yang cocok dengan "$_searchQuery" untuk kategori $_selectedFilter';
                    } else if (_searchQuery.isNotEmpty) {
                      emptyMessage =
                          'Tidak ada proyek yang cocok dengan "$_searchQuery"';
                    } else if (_selectedFilter != 'Semua') {
                      emptyMessage =
                          'Tidak ada proyek untuk kategori $_selectedFilter';
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, i) {
                      final p = filteredProjects[i];
                      String tag;
                      if (p.status == ProjectStatus.tersedia) {
                        tag = 'Pendaftaran';
                      } else {
                        tag = 'Proses';
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _LecturerProjectCard(
                          projectId: p.id,
                          title: p.title,
                          description: p.description,
                          deadline: p.deadline,
                          participants: p.participants,
                          tagLabel: tag,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

// ORIGINAL WIDGETS - NO CHANGES
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
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
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

class _LecturerProjectCard extends StatelessWidget {
  final String projectId;
  final String title;
  final String description;
  final String deadline;
  final String participants;
  final String tagLabel;

  const _LecturerProjectCard({
    required this.projectId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.participants,
    required this.tagLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LecturerProjectDetailScreen(projectId: projectId),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                StatusTag(status: tagLabel),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deadline: $deadline',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                Text(
                  'Partisipan: $participants',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusTag extends StatelessWidget {
  final String status;
  const StatusTag({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2E5AAC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

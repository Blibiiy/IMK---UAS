import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/user_provider.dart';
import 'project_detail_screen.dart';
import 'chat_list_screen.dart';
import 'profile_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Map<String, String> _projectStatuses =
      {}; // projectId -> status for current user

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load projects from Supabase when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjectsAndStatuses();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh status when app resumes
    if (state == AppLifecycleState.resumed) {
      _loadUserStatusForAllProjects();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjectsAndStatuses() async {
    await context.read<ProjectProvider>().loadProjects();
    await _loadUserStatusForAllProjects();
  }

  Future<void> _loadUserStatusForAllProjects() async {
    final userId = context.read<UserProvider>().currentUser?.id;
    if (userId == null) return;

    final projectProvider = context.read<ProjectProvider>();
    final statuses = <String, String>{};

    for (var project in projectProvider.projects) {
      final status = await projectProvider.getUserStatusInProject(
        project.id,
        userId,
      );
      statuses[project.id] = status;
    }

    if (mounted) {
      setState(() {
        _projectStatuses = statuses;
      });
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatListScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadProjectsAndStatuses,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header dengan gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                decoration: AppTheme.headerDecoration(cs),
                child: StudentHeaderCard(
                  name: currentUser?.fullName ?? 'User',
                  program: currentUser?.program ?? 'Program Studi',
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
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PopupMenuButton<String>(
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
                        value: 'Tersedia',
                        child: Text('Tersedia'),
                      ),
                      PopupMenuItem<String>(
                        value: 'Diproses',
                        child: Text('Diproses'),
                      ),
                      PopupMenuItem<String>(
                        value: 'Diterima',
                        child: Text('Diterima'),
                      ),
                      PopupMenuItem<String>(
                        value: 'Selesai',
                        child: Text('Selesai'),
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
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Consumer<ProjectProvider>(
                  builder: (context, projectProvider, child) {
                    // Filter projects based on selected filter and search query
                    final filteredProjects = projectProvider.projects.where((
                      project,
                    ) {
                      // Filter by status
                      final userStatus =
                          _projectStatuses[project.id] ?? 'Tersedia';
                      final statusMatch =
                          _selectedFilter == 'Semua' ||
                          userStatus == _selectedFilter;

                      // Filter by search query
                      final titleMatch =
                          _searchQuery.isEmpty ||
                          project.title.toLowerCase().contains(_searchQuery);

                      return statusMatch && titleMatch;
                    }).toList();

                    if (filteredProjects.isEmpty) {
                      String emptyMessage = 'Tidak ada project';
                      if (_searchQuery.isNotEmpty &&
                          _selectedFilter != 'Semua') {
                        emptyMessage =
                            'Tidak ada project yang cocok dengan "$_searchQuery" untuk kategori $_selectedFilter';
                      } else if (_searchQuery.isNotEmpty) {
                        emptyMessage =
                            'Tidak ada project yang cocok dengan "$_searchQuery"';
                      } else if (_selectedFilter != 'Semua') {
                        emptyMessage =
                            'Tidak ada project untuk kategori $_selectedFilter';
                      }
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            emptyMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredProjects.length,
                      itemBuilder: (context, index) {
                        final project = filteredProjects[index];
                        final userStatus =
                            _projectStatuses[project.id] ?? 'Tersedia';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ProjectCard(
                            projectId: project.id,
                            title: project.title,
                            description: project.description,
                            deadline: project.deadline,
                            participants: project.participants,
                            status: userStatus, // Show user-specific status
                            onTap: () async {
                              // Navigate to detail and wait for result
                              final shouldRefresh = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetailScreen(
                                    projectId: project.id,
                                  ),
                                ),
                              );
                              // Refresh status if user registered
                              if (shouldRefresh == true) {
                                await _loadUserStatusForAllProjects();
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/logos/homeactive.svg',
              width: 24,
              height: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/logos/chat.svg',
              width: 24,
              height: 24,
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/logos/profileinactive.svg',
              width: 24,
              height: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class StudentHeaderCard extends StatelessWidget {
  final String name;
  final String program;
  final String imageUrl;

  const StudentHeaderCard({
    super.key,
    required this.name,
    required this.program,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
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

class ProjectCard extends StatelessWidget {
  final String projectId;
  final String title;
  final String description;
  final String deadline;
  final String participants;
  final String status;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.projectId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.participants,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap:
          onTap ??
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailScreen(projectId: projectId),
            ),
          ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and status tag
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
                StatusTag(status: status),
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
        color: const Color(0xFF2E5AAC), // Blue background
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import 'project_detail_screen.dart';
import 'chat_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onBottomNavTap(int index) {
    if (index == 1) {
      // Navigate to Chat
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatListScreen()),
      );
    } else if (index == 2) {
      // Navigate to Profile
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              // Student Header Card
              const StudentHeaderCard(
                name: 'Muhammad Isra Al Fattah',
                program: 'Prodi Informatika (S1)',
                imageUrl: 'https://placehold.co/100x100/E0E0E0/E0E0E0',
              ),
              const SizedBox(height: 20),
              // Filter Button
              PopupMenuButton<String>(
                onSelected: (String value) {
                  // Handle filter selection
                  // You can implement filter logic here
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'Tersedia',
                    child: Text('Tersedia'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Diproses',
                    child: Text('Diproses'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Diterima',
                    child: Text('Diterima'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.filter_list, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Projects List
              Consumer<ProjectProvider>(
                builder: (context, projectProvider, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projectProvider.projects.length,
                    itemBuilder: (context, index) {
                      final project = projectProvider.projects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ProjectCard(
                          projectId: project.id,
                          title: project.title,
                          description: project.description,
                          deadline: project.deadline,
                          participants: project.participants,
                          status: project.statusText,
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFE0E0E0),
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/logos/homeactive.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/logos/chat.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/logos/profileinactive.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Student Header Card Component
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(20),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  program,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Project Card Component
class ProjectCard extends StatelessWidget {
  final String projectId;
  final String title;
  final String description;
  final String deadline;
  final String participants;
  final String status;

  const ProjectCard({
    super.key,
    required this.projectId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.participants,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailScreen(projectId: projectId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StatusTag(status: status),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            // Deadline and Participants
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deadline: $deadline',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Partisipan: $participants',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Status Tag Component
class StatusTag extends StatelessWidget {
  final String status;

  const StatusTag({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

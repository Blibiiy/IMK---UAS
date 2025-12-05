import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/user_provider.dart';
import '../providers/chat_provider.dart'; // NEW
import '../screens/home_screen.dart';
import '../screens/chat_list_screen.dart';
import 'portfolio_detail_screen.dart';
import 'portfolio_form_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super. key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserProvider>().currentUser?. id;
      context.read<PortfolioProvider>().loadPortfolios(userId: userId);
      
      // Load conversations untuk badge counter
      if (userId != null) {
        context. read<ChatProvider>().loadConversations(userId);
      }
    });
  }

  // Calculate total unread count
  int _getTotalUnreadCount() {
    final conversations = context.watch<ChatProvider>().conversations;
    return conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider. currentUser;
    final totalUnread = _getTotalUnreadCount();

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card (inline, tidak pakai widget terpisah)
            Container(
              width: double.infinity,
              padding: const EdgeInsets. fromLTRB(16, 50, 16, 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E5AAC), Color(0xFF00A8E8)],
                  begin: Alignment.topLeft,
                  end: Alignment. bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: currentUser?.avatarUrl != null
                        ? NetworkImage(currentUser! .avatarUrl!)
                        : null,
                    backgroundColor: Colors.white. withOpacity(0.3),
                    child: currentUser?.avatarUrl == null
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?. fullName ?? 'User',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentUser?.program ?? 'Program Studi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors. white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Portfolio Header with + button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Portfolio',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PortfolioFormScreen(),
                            ),
                          );
                        },
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add, color: cs.onPrimary, size: 24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Portfolio List
                  Consumer<PortfolioProvider>(
                    builder: (context, portfolioProvider, child) {
                      if (portfolioProvider.portfolioItems.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'Belum ada portfolio',
                              style: TextStyle(
                                fontSize: 16,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView. builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: portfolioProvider.portfolioItems.length,
                        itemBuilder: (context, index) {
                          final item = portfolioProvider.portfolioItems[index];
                          return Padding(
                            padding: const EdgeInsets. only(bottom: 16.0),
                            child: PortfolioCard(item: item),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Logout Button
                  GestureDetector(
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
                            'assets/logos/logout. svg',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight. w500,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation with Badge (consistent with HomeScreen)
      bottomNavigationBar: BottomAppBar(
        color: cs.surfaceVariant,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home_outlined, size: 28), // Pastikan 28
              color: cs.onSurfaceVariant,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, size: 28), // Pastikan 28
                  color: cs.onSurfaceVariant,
                  onPressed: () {
                    Navigator. push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatListScreen(),
                      ),
                    );
                  },
                ),
                if (totalUnread > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surfaceVariant, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.person, size: 28), // Pastikan 28
              color: cs.primary,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable PortfolioCard Component
class PortfolioCard extends StatelessWidget {
  final PortfolioItem item;

  const PortfolioCard({super.key, required this.item});

  String _getSubText() {
    switch (item.runtimeType) {
      case ProjectPortfolio:
        final project = item as ProjectPortfolio;
        return 'Dosen Pembimbing: ${project.lecturer}';
      case CertificatePortfolio:
        final certificate = item as CertificatePortfolio;
        return 'Diterbitkan Oleh: ${certificate.issuer}';
      case OrganizationPortfolio:
        final organization = item as OrganizationPortfolio;
        return 'Posisi: ${organization.position}';
      default:
        return '';
    }
  }

  String _getExtraInfo() {
    switch (item.runtimeType) {
      case ProjectPortfolio:
        final project = item as ProjectPortfolio;
        return 'Tanggal Selesai: ${project.deadline}';
      case CertificatePortfolio:
        final certificate = item as CertificatePortfolio;
        return 'Berlaku: ${certificate. startDate} - ${certificate.endDate}';
      case OrganizationPortfolio:
        final organization = item as OrganizationPortfolio;
        return 'Masa Jabatan: ${organization.duration}';
      default:
        return '';
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
            builder: (context) => PortfolioDetailScreen(item: item),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets. all(16.0),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment. start,
          children: [
            Text(
              item.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getSubText(),
              style: TextStyle(fontSize: 14, color: cs.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              _getExtraInfo(),
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
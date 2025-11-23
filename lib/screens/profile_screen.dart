import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/user_provider.dart';
import '../screens/home_screen.dart';
import '../screens/chat_list_screen.dart';
import 'portfolio_detail_screen.dart';
import 'portfolio_form_screen.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 2; // Profile tab is selected

  @override
  void initState() {
    super.initState();
    // Load portfolios from Supabase when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserProvider>().currentUser?.id;
      context.read<PortfolioProvider>().loadPortfolios(userId: userId);
    });
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      // Navigate to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 1) {
      // Navigate to Chat
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatListScreen()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan gradient (konsisten dengan HomeScreen)
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
                          // Navigate to Add Portfolio (Create mode)
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
                  // Portfolio List using Consumer
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

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: portfolioProvider.portfolioItems.length,
                        itemBuilder: (context, index) {
                          final item = portfolioProvider.portfolioItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
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
                      // Handle logout
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/logos/homeinactive.svg',
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
              'assets/logos/profileactive.svg',
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

// Reusable PortfolioCard Component
class PortfolioCard extends StatelessWidget {
  final PortfolioItem item;

  const PortfolioCard({super.key, required this.item});

  String _getSubText() {
    // Use switch on runtimeType to determine the correct sub-text
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
        return 'Berlaku: ${certificate.startDate} - ${certificate.endDate}';
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
        // Navigate to detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PortfolioDetailScreen(item: item),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              item.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            // Sub text (dynamic based on type)
            Text(
              _getSubText(),
              style: TextStyle(fontSize: 14, color: cs.onSurface),
            ),
            const SizedBox(height: 4),
            // Extra info (dynamic based on type)
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

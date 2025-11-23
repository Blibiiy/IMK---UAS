import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/project_provider.dart';
import '../providers/portfolio_provider.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'portfolio_detail_screen.dart';

class StudentProfileDetailScreen extends StatefulWidget {
  final Student student;

  const StudentProfileDetailScreen({super.key, required this.student});

  @override
  State<StudentProfileDetailScreen> createState() =>
      _StudentProfileDetailScreenState();
}

class _StudentProfileDetailScreenState
    extends State<StudentProfileDetailScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<PortfolioItem> _portfolioItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    try {
      setState(() => _isLoading = true);

      // Load all three types of portfolio
      final projects = await _supabaseService.getPortfolioProjectsByUserId(
        widget.student.id,
      );
      final certificates = await _supabaseService
          .getPortfolioCertificatesByUserId(widget.student.id);
      final organizations = await _supabaseService
          .getPortfolioOrganizationsByUserId(widget.student.id);

      // Convert to portfolio items
      final List<PortfolioItem> items = [];

      for (final project in projects) {
        items.add(ProjectPortfolio.fromJson(project));
      }
      for (final cert in certificates) {
        items.add(CertificatePortfolio.fromJson(cert));
      }
      for (final org in organizations) {
        items.add(OrganizationPortfolio.fromJson(org));
      }

      setState(() {
        _portfolioItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading portfolio: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/logos/back.svg',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Body berisi Card Identitas + Portfolio
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Card Identitas Mahasiswa (sama seperti di profil)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                widget.student.avatarUrl,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.student.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.student.program,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Portfolio Section
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
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_portfolioItems.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'Belum ada portfolio',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _portfolioItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = _portfolioItems[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PortfolioDetailScreen(
                                      item: item,
                                      isViewOnly:
                                          true, // Dosen hanya melihat, tidak bisa edit/delete
                                    ),
                                  ),
                                );
                              },
                              child: _PortfolioCompactCard(item: item),
                            );
                          },
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioCompactCard extends StatelessWidget {
  final PortfolioItem item;

  const _PortfolioCompactCard({required this.item});

  String _getSubText() {
    if (item is ProjectPortfolio) {
      final p = item as ProjectPortfolio;
      return 'Dosen Pembimbing: ${p.lecturer}';
    } else if (item is CertificatePortfolio) {
      final c = item as CertificatePortfolio;
      return 'Diterbitkan Oleh: ${c.issuer}';
    } else if (item is OrganizationPortfolio) {
      final o = item as OrganizationPortfolio;
      return 'Posisi: ${o.position}';
    }
    return '';
  }

  String _getExtraInfo() {
    if (item is ProjectPortfolio) {
      final p = item as ProjectPortfolio;
      return 'Tanggal Selesai: ${p.deadline}';
    } else if (item is CertificatePortfolio) {
      final c = item as CertificatePortfolio;
      return 'Berlaku: ${c.startDate} - ${c.endDate}';
    } else if (item is OrganizationPortfolio) {
      final o = item as OrganizationPortfolio;
      return 'Masa Jabatan: ${o.duration}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}

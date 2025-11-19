import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/project_provider.dart';
import '../providers/portfolio_provider.dart';

class StudentProfileDetailScreen extends StatelessWidget {
  final Student student;

  const StudentProfileDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header abu-abu dengan back (kiri) + konten di TENGAH (avatar, nama, prodi)
            Container(
              width: double.infinity,
              color: const Color(0xFFE0E0E0),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Stack(
                children: [
                  // Back di kiri
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: SvgPicture.asset('assets/logos/back.svg', width: 24, height: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Konten dipusatkan
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        CircleAvatar(
                          radius: 44,
                          backgroundImage: NetworkImage(student.avatarUrl),
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          student.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student.program,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body berisi Portfolio (judul dan isi dipusatkan sesuai permintaan)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF5F5F5),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Judul di TENGAH
                        const Text(
                          'Portfolio',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        if (student.portfolio.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'Belum ada portfolio',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: student.portfolio
                                .map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: _PortfolioCompactCard(item: item),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
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

  @override
  Widget build(BuildContext context) {
    // Kartu abu-abu membulat sesuai mockup
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFBDBDBD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildInner(),
    );
  }

  Widget _buildInner() {
    if (item is ProjectPortfolio) {
      final p = item as ProjectPortfolio;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _truncate(p.title),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Dosen Pembimbing: ${p.lecturer}',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          Text(
            'Tanggal Selesai: ${p.deadline}',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      );
    } else if (item is CertificatePortfolio) {
      final c = item as CertificatePortfolio;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _truncate(c.title),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Diterbitkan Oleh: ${c.issuer}',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          Text(
            'Tanggal Berlaku: ${c.startDate} - ${c.endDate}',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      );
    } else if (item is OrganizationPortfolio) {
      final o = item as OrganizationPortfolio;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _truncate(o.title),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Posisi: ${o.position}',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          Text(
            'Masa Jabatan: ${o.duration}',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      );
    } else {
      return const Text('Unknown portfolio type');
    }
  }

  String _truncate(String text, {int max = 28}) {
    if (text.length <= max) return text;
    return '${text.substring(0, max)}..';
  }
}
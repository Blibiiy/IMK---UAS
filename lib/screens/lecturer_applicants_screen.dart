import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/project_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/chat_provider.dart'; // NEW
import 'lecturer_members_screen.dart';
import 'student_profile_detail_screen.dart';

class LecturerApplicantsScreen extends StatefulWidget {
  final String projectId;

  const LecturerApplicantsScreen({super.key, required this.projectId});

  @override
  State<LecturerApplicantsScreen> createState() =>
      _LecturerApplicantsScreenState();
}

class _LecturerApplicantsScreenState extends State<LecturerApplicantsScreen> {
  @override
  void initState() {
    super.initState();
    // Load applicants from database when screen opens
    WidgetsBinding. instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadApplicants(widget.projectId);
    });
  }

  Future<void> _accept(BuildContext context, String studentId) async {
    try {
      // Pass ChatProvider untuk auto-add ke group chat
      await context.read<ProjectProvider>().acceptApplicant(
            widget.projectId,
            studentId,
            context.read<ChatProvider>(), // NEW
          );
      if (! mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mahasiswa berhasil diterima dan ditambahkan ke grup chat'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menerima mahasiswa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reject(BuildContext context, String studentId) async {
    try {
      await context.read<ProjectProvider>(). rejectApplicant(
            widget.projectId,
            studentId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mahasiswa berhasil ditolak')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menolak mahasiswa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context). colorScheme;
    final project = context.watch<ProjectProvider>().getProjectById(
      widget.projectId,
    );

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + Button Anggota
              Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/logos/back. svg',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () => Navigator. pop(context),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LecturerMembersScreen(
                            projectId: widget.projectId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton. styleFrom(
                      backgroundColor: const Color(0xFF2E5AAC),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Anggota',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: project == null
                    ? const Center(child: Text('Project tidak ditemukan'))
                    : project.applicants.isEmpty
                        ? Center(
                            child: Text(
                              'Belum Ada Pendaftar',
                              style: TextStyle(
                                fontSize: 16,
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: project.applicants.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final applicant = project.applicants[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StudentProfileDetailScreen(
                                        student: applicant,
                                      ),
                                    ),
                                  );
                                },
                                child: _ApplicantCard(
                                  applicant: applicant,
                                  onAccept: () => _accept(context, applicant.id),
                                  onReject: () => _reject(context, applicant.id),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Student applicant;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ApplicantCard({
    required this.applicant,
    required this.onAccept,
    required this.onReject,
  });

  List<String> _getTopSkills() {
    final skills = <String>{};
    for (var item in applicant.portfolio) {
      if (item is CertificatePortfolio) {
        skills. addAll(item.skills);
      }
    }
    return skills.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context). colorScheme;
    final topSkills = _getTopSkills();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs. surfaceVariant,
        borderRadius: BorderRadius.circular(12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(applicant.avatarUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      applicant.program,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs. onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5AAC),
                      foregroundColor: Colors. white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      minimumSize: const Size(70, 32),
                    ),
                    child: const Text(
                      'Terima',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton. styleFrom(
                      foregroundColor: const Color(0xFFD32F2F),
                      side: const BorderSide(
                        color: Color(0xFFD32F2F),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      minimumSize: const Size(70, 32),
                    ),
                    child: const Text(
                      'Tolak',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (topSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: topSkills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E5AAC). withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2E5AAC).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E5AAC),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
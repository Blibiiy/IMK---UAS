import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/project_provider.dart';
import '../providers/portfolio_provider.dart';
import 'lecturer_applicants_screen.dart';
import 'student_profile_detail_screen.dart';

class LecturerMembersScreen extends StatefulWidget {
  final String projectId;

  const LecturerMembersScreen({super.key, required this.projectId});

  @override
  State<LecturerMembersScreen> createState() => _LecturerMembersScreenState();
}

class _LecturerMembersScreenState extends State<LecturerMembersScreen> {
  @override
  void initState() {
    super.initState();
    // Load members from database when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadMembers(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final project = context.watch<ProjectProvider>().getProjectById(
      widget.projectId,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + Button Pendaftar
              Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/logos/back.svg',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  // Hide Pendaftar button if project is finished
                  if (project != null &&
                      project.status != ProjectStatus.selesai)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LecturerApplicantsScreen(
                              projectId: widget.projectId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
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
                        'Pendaftar',
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
                    : project.members.isEmpty
                    ? Center(
                        child: Text(
                          'Belum Ada Anggota',
                          style: TextStyle(
                            fontSize: 16,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: project.members.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final member = project.members[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentProfileDetailScreen(
                                    student: member,
                                  ),
                                ),
                              );
                            },
                            child: _MemberCard(member: member),
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

class _MemberCard extends StatelessWidget {
  final Student member;
  const _MemberCard({required this.member});

  List<String> _getTopSkills() {
    final skills = <String>{};
    for (var item in member.portfolio) {
      if (item is CertificatePortfolio) {
        skills.addAll(item.skills);
      }
    }
    return skills.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final topSkills = _getTopSkills();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
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
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(member.avatarUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.program,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
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
                    color: const Color(0xFF2E5AAC).withOpacity(0.1),
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

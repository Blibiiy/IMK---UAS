import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/project_provider.dart';
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
                  OutlinedButton(
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.5),
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(member.avatarUrl),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 6),
                Text(
                  member.program,
                  style: TextStyle(fontSize: 13, color: cs.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

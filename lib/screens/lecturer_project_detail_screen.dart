import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/project_provider.dart';
import '../widgets/confirm_close_dialog.dart';
import '../widgets/success_dialog.dart';
import 'lecturer_edit_project_screen.dart';
import 'lecturer_members_screen.dart';

class LecturerProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const LecturerProjectDetailScreen({super.key, required this.projectId});

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 30) return '${diff.inDays} hari yang lalu';
    final months = (diff.inDays / 30).floor();
    if (months < 12) return '$months bulan yang lalu';
    final years = (diff.inDays / 365).floor();
    return '$years tahun yang lalu';
  }

  void _confirmCloseRegistration(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ConfirmCloseDialog(
        title: 'Apakah Anda Yakin?',
        subtitle:
            'Tekan “Ya” jika anda yakin untuk menutup pendaftaran, “Tidak” jika tidak ingin',
        onConfirm: () {
          // Update status proyek
          context.read<ProjectProvider>().closeRegistration(projectId);

          // Success popup
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const SuccessDialog(
              message: 'Penutupan Pendaftaran project Telah selesai !',
            ),
          );
        },
      ),
    );
  }

  void _confirmCompleteProject(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ConfirmCloseDialog(
        title: 'Selesaikan Project?',
        subtitle:
            'Tekan "Ya" jika project sudah selesai dikerjakan, "Tidak" jika belum',
        onConfirm: () {
          // Update status proyek menjadi selesai
          context.read<ProjectProvider>().completeProject(projectId);

          // Success popup
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) =>
                const SuccessDialog(message: 'Project telah diselesaikan!'),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>().getProjectById(projectId);
    if (project == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Project tidak ditemukan')),
      );
    }

    final postedFormatted = DateFormat('dd MMMM yyyy').format(project.postedAt);
    final postedAgo = _timeAgo(project.postedAt);

    final cs = Theme.of(context).colorScheme;
    final isOpen = project.status == ProjectStatus.tersedia;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + Edit
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
                          builder: (_) =>
                              LecturerEditProjectScreen(projectId: projectId),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.onSurface,
                      side: BorderSide(color: cs.outline, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                project.title,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Supervisor
              Text(
                project.supervisor,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),

              // Deadline
              Text(
                'Deadline: ${project.deadline}',
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),

              // Diposting
              Text(
                'Diposting: $postedFormatted • $postedAgo',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (project.editedAt != null) ...[
                const SizedBox(height: 2),
                Text(
                  '(Diedit)',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              const SizedBox(height: 12),
              Divider(thickness: 1, color: cs.outline),
              const SizedBox(height: 16),

              // Persyaratan Project
              Text(
                'Persyaratan Project :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (project.requirements.isEmpty)
                Text(
                  '-',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: cs.onSurface,
                  ),
                )
              else
                ...project.requirements.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '${e.key + 1}. ${e.value}',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Detail Project
              Text(
                'Detail Project :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                project.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(height: 48),

              // Buttons: List Anggota + (conditionally) Tutup Pendaftaran atau Selesaikan Project
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LecturerMembersScreen(projectId: projectId),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.onSurface,
                        side: BorderSide(color: cs.outline, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'List Anggota',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (isOpen)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _confirmCloseRegistration(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.onSurface,
                          side: BorderSide(color: cs.outline, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Tutup Pendaftaran',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (!isOpen && project.status != ProjectStatus.selesai)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _confirmCompleteProject(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.onSurface,
                          side: BorderSide(color: cs.outline, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Selesaikan Project',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

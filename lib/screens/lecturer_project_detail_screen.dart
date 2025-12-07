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
                  // Hide edit button if project is finished
                  if (project.status != ProjectStatus.selesai)
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 18, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dosen: ${project.supervisor}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Deadline: ${project.deadline}',
                            style: TextStyle(
                              fontSize: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 18, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Diposting: $postedFormatted • $postedAgo',
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (project.editedAt != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Telah diedit',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Persyaratan Project
              Text(
                'Persyaratan Project',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (project.requirements.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tidak ada persyaratan khusus',
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...project.requirements.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Detail Project
              Text(
                'Detail Project',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                project.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(height: 32),

              // Buttons with better design
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LecturerMembersScreen(projectId: projectId),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.group_outlined,
                        size: 20,
                        color: cs.primary,
                      ),
                      label: Text(
                        'List Anggota',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cs.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (isOpen)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmCloseRegistration(context),
                        icon: const Icon(Icons.close, size: 20),
                        label: const Text(
                          'Tutup Pendaftaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  if (!isOpen && project.status != ProjectStatus.selesai)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmCompleteProject(context),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text(
                          'Selesaikan Project',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
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

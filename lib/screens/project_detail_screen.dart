import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../widgets/confirmation_dialog.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmationDialog(
          title: 'Apakah Anda Yakin?',
          description:
              'Tekan "Ya" jika anda yakin untuk mendaftarkan diri ke project, "Tidak" jika tidak ingin',
          onConfirm: () {
            // Daftar project
            Provider.of<ProjectProvider>(
              context,
              listen: false,
            ).registerProject(projectId);
            // Tampilkan dialog sukses
            _showSuccessDialog(context);
          },
          confirmText: 'Ya',
          cancelText: 'Tidak',
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol X di pojok kanan atas
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: SvgPicture.asset(
                        'assets/logos/close.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Icon checkmark hitam
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/logos/done.svg',
                      width: 40,
                      height: 40,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pendaftaran project berhasil dilakukan!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = Provider.of<ProjectProvider>(
      context,
    ).getProjectById(projectId);

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/logos/back.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                project.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Supervisor
              Text(
                project.supervisor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              // Deadline
              Text(
                'Deadline: ${project.deadline}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              // Description
              Text(
                project.description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              // Persyaratan Project
              const Text(
                'Persyaratan Project :',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...project.requirements.map(
                (requirement) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    requirement,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Manfaat Melakukan Project
              const Text(
                'Manfaat Melakukan Project :',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...project.benefits.map(
                (benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    benefit,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Buttons
              Row(
                children: [
                  // Chat Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle chat
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Chat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Daftar Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: project.status == ProjectStatus.tersedia
                          ? () => _showConfirmationDialog(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: const Text(
                        'Daftar >>',
                        style: TextStyle(
                          fontSize: 16,
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

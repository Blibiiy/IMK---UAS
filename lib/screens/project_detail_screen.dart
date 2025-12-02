import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/success_dialog.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  String _userStatus = 'Tersedia';
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    final userId = context.read<UserProvider>().currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoadingStatus = false;
      });
      return;
    }

    final status = await context.read<ProjectProvider>().getUserStatusInProject(
      widget.projectId,
      userId,
    );

    setState(() {
      _userStatus = status;
      _isLoadingStatus = false;
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmationDialog(
          title: 'Apakah Anda Yakin?',
          description:
              'Tekan "Ya" jika anda yakin untuk mendaftarkan diri ke project, "Tidak" jika tidak ingin',
          onConfirm: () async {
            // Show loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            try {
              await Provider.of<ProjectProvider>(
                context,
                listen: false,
              ).registerProject(widget.projectId, currentUser.id);

              // Reload user status after successful registration
              await _loadUserStatus();

              if (!context.mounted) return;
              Navigator.pop(context); // Close loading

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => SuccessDialog(
                  message: 'Pendaftaran project berhasil dilakukan!',
                  onClose: () {
                    // Just close the success dialog, stay on project detail page
                    Navigator.of(dialogContext).pop();
                    // User status already reloaded, button will update automatically
                  },
                ),
              );
            } catch (e) {
              if (!context.mounted) return;
              Navigator.pop(context); // Close loading

              // Parse error message untuk tampilkan yang lebih user-friendly
              String errorMessage = 'Gagal mendaftar ke project';
              final errorString = e.toString();

              if (errorMessage.contains('sudah mendaftar')) {
                errorMessage = 'Anda sudah mendaftar ke project ini sebelumnya';
              } else if (errorString.contains('duplicate key') ||
                  errorString.contains('23505')) {
                errorMessage = 'Anda sudah mendaftar ke project ini sebelumnya';
              } else if (errorString.contains('Exception:')) {
                // Extract message from Exception
                final match = RegExp(
                  r'Exception: (.+)',
                ).firstMatch(errorString);
                if (match != null) {
                  errorMessage = match.group(1) ?? errorMessage;
                }
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          confirmText: 'Ya',
          cancelText: 'Tidak',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final project = Provider.of<ProjectProvider>(
      context,
    ).getProjectById(widget.projectId);
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
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/logos/back.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              project.supervisor,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Deadline: ${project.deadline}',
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Divider(color: cs.outline, thickness: 1),
            const SizedBox(height: 16),
            Text(
              project.description,
              style: TextStyle(fontSize: 14, height: 1.5, color: cs.onSurface),
            ),
            const SizedBox(height: 24),
            Text(
              'Persyaratan Project :',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...project.requirements.map(
              (requirement) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  requirement,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Manfaat Melakukan Project :',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...project.benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  benefit,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Hanya tampilkan tombol jika bukan status Selesai
            if (_userStatus != 'Selesai')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Chat'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoadingStatus
                          ? null
                          : (project.status == ProjectStatus.tersedia &&
                                _userStatus == 'Tersedia')
                          ? () => _showConfirmationDialog(context)
                          : null,
                      child: Text(
                        _isLoadingStatus
                            ? 'Loading...'
                            : _userStatus == 'Diproses'
                            ? 'Diproses'
                            : _userStatus == 'Diterima'
                            ? 'Sudah Diterima'
                            : 'Daftar >>',
                      ),
                    ),
                  ),
                ],
              ),
            // Tampilkan status Selesai jika project sudah selesai
            if (_userStatus == 'Selesai')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5AAC), // Blue background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Project Selesai',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

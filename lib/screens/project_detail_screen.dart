import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/user_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/success_dialog.dart';
import 'chat_detail_screen.dart';

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

              await _loadUserStatus();

              if (!context.mounted) return;
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => SuccessDialog(
                  message: 'Pendaftaran project berhasil dilakukan! ',
                  onClose: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              );
            } catch (e) {
              if (!context.mounted) return;
              Navigator.pop(context);

              String errorMessage = 'Gagal mendaftar ke project';
              final errorString = e.toString();

              if (errorString.contains('sudah mendaftar')) {
                errorMessage = 'Anda sudah mendaftar ke project ini sebelumnya';
              } else if (errorString.contains('duplicate key') ||
                  errorString.contains('23505')) {
                errorMessage = 'Anda sudah mendaftar ke project ini sebelumnya';
              } else if (errorString.contains('Exception:')) {
                final match = RegExp(
                  r'Exception: (. +)',
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

  Future<void> _handleChatWithLecturer() async {
    final currentUser = context.read<UserProvider>().currentUser;
    final project = context.read<ProjectProvider>().getProjectById(
      widget.projectId,
    );

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu')),
      );
      return;
    }

    if (project == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Project tidak ditemukan')));
      return;
    }

    print('🔍 Current user: ${currentUser.id}');
    print('🔍 Project supervisor ID: ${project.supervisorId}');

    if (project.supervisorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ID dosen tidak tersedia.  Pastikan project dibuat dengan benar.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chatProvider = context.read<ChatProvider>();
      final conversationId = await chatProvider.getOrCreatePrivateChat(
        currentUser.id,
        project.supervisorId,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (conversationId != null) {
        await chatProvider.loadConversations(currentUser.id);

        if (!mounted) return;

        final conversation = chatProvider.conversations
            .where((c) => c.id == conversationId)
            .firstOrNull;

        if (conversation != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(conversation: conversation),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chat berhasil dibuat, silakan cek halaman Chat'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal membuat chat.  Periksa koneksi dan coba lagi.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error in _handleChatWithLecturer: $e');

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
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
        backgroundColor: cs.surface,
        elevation: 0,
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
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Deskripsi Project
            Text(
              'Deskripsi Project',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              project.description,
              style: TextStyle(fontSize: 14, height: 1.6, color: cs.onSurface),
            ),
            const SizedBox(height: 24),
            Text(
              'Persyaratan Project',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 32),
            // Buttons with better design
            if (_userStatus != 'Selesai')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleChatWithLecturer,
                      icon: Icon(
                        Icons.chat_outlined,
                        size: 20,
                        color: cs.primary,
                      ),
                      label: Text(
                        'Chat Dosen',
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
                  Expanded(
                    child: _buildActionButton(context, _userStatus, project),
                  ),
                ],
              ),
            if (_userStatus == 'Selesai')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Project Selesai',
                      style: TextStyle(
                        fontSize: 18,
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

  // FIXED: Build action button dengan consistent styling
  Widget _buildActionButton(
    BuildContext context,
    String status,
    Project project,
  ) {
    final cs = Theme.of(context).colorScheme;

    // Base styling untuk semua button
    const basePadding = EdgeInsets.symmetric(vertical: 16);
    const baseTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    final baseBorderRadius = BorderRadius.circular(8);

    if (status == 'Tersedia') {
      return ElevatedButton(
        onPressed: project.status == ProjectStatus.tersedia
            ? () => _showConfirmationDialog(context)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          padding: basePadding,
          shape: RoundedRectangleBorder(borderRadius: baseBorderRadius),
        ),
        child: const Text('Daftar >>', style: baseTextStyle),
      );
    } else if (status == 'Diproses') {
      return Container(
        padding: basePadding,
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: baseBorderRadius,
          border: Border.all(color: Colors.orange, width: 2),
        ),
        child: const Center(
          child: Text(
            'Diproses',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
      );
    } else if (status == 'Ditolak') {
      return Container(
        padding: basePadding,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: baseBorderRadius,
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: const Center(
          child: Text(
            'Ditolak',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      );
    } else if (status == 'Diterima') {
      return Container(
        padding: basePadding,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: baseBorderRadius,
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: const Center(
          child: Text(
            'Diterima',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

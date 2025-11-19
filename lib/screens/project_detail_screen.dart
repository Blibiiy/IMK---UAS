import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/success_dialog.dart';

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
            Provider.of<ProjectProvider>(context, listen: false).registerProject(projectId);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const SuccessDialog(
                message: 'Pendaftaran project berhasil dilakukan!',
              ),
            );
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
    final project = Provider.of<ProjectProvider>(context).getProjectById(projectId);
    if (project == null) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
        body: const Center(child: Text('Project tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset('assets/logos/back.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(project.title, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(project.supervisor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
          const SizedBox(height: 4),
          Text('Deadline: ${project.deadline}', style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),
          Divider(color: cs.outline, thickness: 1),
          const SizedBox(height: 16),
          Text(project.description, style: TextStyle(fontSize: 14, height: 1.5, color: cs.onSurface)),
          const SizedBox(height: 24),
          Text('Persyaratan Project :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 12),
          ...project.requirements.map((requirement) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(requirement, style: TextStyle(fontSize: 14, height: 1.5, color: cs.onSurface)),
              )),
          const SizedBox(height: 24),
          Text('Manfaat Melakukan Project :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 12),
          ...project.benefits.map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(benefit, style: TextStyle(fontSize: 14, height: 1.5, color: cs.onSurface)),
              )),
          const SizedBox(height: 40),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Chat'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: project.status == ProjectStatus.tersedia ? () => _showConfirmationDialog(context) : null,
                child: const Text('Daftar >>'),
              ),
            ),
          ]),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}
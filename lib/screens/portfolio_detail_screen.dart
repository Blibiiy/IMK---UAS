import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/confirmation_dialog.dart';
import 'portfolio_form_screen.dart';

class PortfolioDetailScreen extends StatelessWidget {
  final PortfolioItem item;
  final bool isViewOnly;

  const PortfolioDetailScreen({
    super.key,
    required this.item,
    this.isViewOnly = false,
  });

  Future<void> _openCertificateFile(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildProjectDetail(BuildContext context) {
    final project = item as ProjectPortfolio;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        IconButton(
          icon: SvgPicture.asset(
            'assets/logos/back.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 8),

        // Title
        Text(
          project.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withOpacity(0.2), width: 1),
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
                      'Dosen: ${project.lecturer}',
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
                      'Selesai: ${project.deadline}',
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

        // Description
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

        // Requirements
        Text(
          'Persyaratan Project',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...project.requirements.asMap().entries.map((entry) {
          return Padding(
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
          );
        }),

        const SizedBox(height: 24),

        // Benefits
        Text(
          'Manfaat Melakukan Project',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...project.benefits.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${entry.key + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cs.onSecondaryContainer,
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
          );
        }),
      ],
    );
  }

  Widget _buildCertificateDetail(BuildContext context) {
    final certificate = item as CertificatePortfolio;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        IconButton(
          icon: SvgPicture.asset(
            'assets/logos/back.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 8),

        // Title
        Text(
          certificate.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.business, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Diterbitkan Oleh: ${certificate.issuer}',
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
                      'Berlaku: ${certificate.startDate} - ${certificate.endDate}',
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

        // Skills Section
        Text(
          'Skill Yang Didapatkan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Skills as chips for better visual
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: certificate.skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: cs.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onPrimaryContainer,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Certificate file section with better design
        Text(
          'Bukti Sertifikat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        if (certificate.certificateFile != null &&
            certificate.certificateFile!.isNotEmpty)
          InkWell(
            onTap: () =>
                _openCertificateFile(context, certificate.certificateFile!),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      certificate.certificateFile!.toLowerCase().contains(
                            '.pdf',
                          )
                          ? Icons.picture_as_pdf
                          : Icons.image,
                      size: 28,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lihat Sertifikat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          certificate.certificateFile!.toLowerCase().contains(
                                '.pdf',
                              )
                              ? 'File PDF'
                              : 'File Gambar',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new, color: cs.primary, size: 20),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tidak ada file yang dilampirkan',
                    style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        if (!isViewOnly) ...[
          const SizedBox(height: 32),
          // Edit and Delete buttons with better design
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to Edit mode
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PortfolioFormScreen(existingItem: item),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit_outlined, size: 20, color: cs.primary),
                  label: Text(
                    'Edit',
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
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Hapus Portfolio',
                        description:
                            'Apakah Anda yakin ingin menghapus portfolio ini?',
                        onConfirm: () {
                          // Delete portfolio
                          Provider.of<PortfolioProvider>(
                            context,
                            listen: false,
                          ).deletePortfolio(item.id);
                          // Close detail screen and dialog
                          Navigator.pop(context); // Close detail screen
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
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
        ],
      ],
    );
  }

  Widget _buildOrganizationDetail(BuildContext context) {
    final organization = item as OrganizationPortfolio;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        IconButton(
          icon: SvgPicture.asset(
            'assets/logos/back.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 8),

        // Title
        Text(
          organization.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.work_outline, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Posisi: ${organization.position}',
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
                      'Masa Jabatan: ${organization.duration}',
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

        // Description/Contributions
        Text(
          'Kegiatan Dan Kontribusi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          organization.description,
          style: TextStyle(fontSize: 14, height: 1.6, color: cs.onSurface),
        ),
        if (!isViewOnly) ...[
          const SizedBox(height: 32),
          // Edit and Delete buttons with better design
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to Edit mode
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PortfolioFormScreen(existingItem: item),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit_outlined, size: 20, color: cs.primary),
                  label: Text(
                    'Edit',
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
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Hapus Portfolio',
                        description:
                            'Apakah Anda yakin ingin menghapus portfolio ini?',
                        onConfirm: () {
                          // Delete portfolio
                          Provider.of<PortfolioProvider>(
                            context,
                            listen: false,
                          ).deletePortfolio(item.id);
                          // Close detail screen and dialog
                          Navigator.pop(context); // Close detail screen
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
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
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Use switch on runtimeType to determine which layout to render
    switch (item.runtimeType) {
      case ProjectPortfolio:
        return _buildProjectDetail(context);
      case CertificatePortfolio:
        return _buildCertificateDetail(context);
      case OrganizationPortfolio:
        return _buildOrganizationDetail(context);
      default:
        return const Center(child: Text('Unknown portfolio type'));
    }
  }
}

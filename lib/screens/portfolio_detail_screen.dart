import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/confirmation_dialog.dart';
import 'portfolio_form_screen.dart';

class PortfolioDetailScreen extends StatelessWidget {
  final PortfolioItem item;

  const PortfolioDetailScreen({super.key, required this.item});

  Widget _buildProjectDetail() {
    final project = item as ProjectPortfolio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        const BackButton(color: Colors.black),
        const SizedBox(height: 16),
        // Title
        Text(
          project.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Lecturer info
        Text(
          'Dosen: ${project.lecturer}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          'Selesai: ${project.deadline}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        // Description
        Text(project.description, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        // Requirements
        const Text(
          'Persyaratan Project :',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...project.requirements.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${entry.key + 1}. ${entry.value}',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }),
        const SizedBox(height: 16),
        // Benefits
        const Text(
          'Manfaat Melakukan Project :',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...project.benefits.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${entry.key + 1}. ${entry.value}',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCertificateDetail(BuildContext context) {
    final certificate = item as CertificatePortfolio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        const BackButton(color: Colors.black),
        const SizedBox(height: 16),
        // Title
        Text(
          certificate.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Issuer info
        Text(
          'Diterbitkan Oleh: ${certificate.issuer}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          'Berlaku: ${certificate.startDate} - ${certificate.endDate}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        // Skills
        const Text(
          'Skill Yang Didapatkan :',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...certificate.skills.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${entry.key + 1}. ${entry.value}',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }),
        const SizedBox(height: 16),
        // Certificate file
        const Text(
          'Bukti Sertifikat',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/logos/image.svg', width: 20, height: 20),
              const SizedBox(width: 8),
              Text(
                certificate.certificateFile ?? 'No file',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Edit and Delete buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
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
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrganizationDetail(BuildContext context) {
    final organization = item as OrganizationPortfolio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        const BackButton(color: Colors.black),
        const SizedBox(height: 16),
        // Title
        Text(
          organization.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Position info
        Text(
          'Posisi: ${organization.position}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          'Masa Jabatan: ${organization.duration}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        // Description/Contributions
        const Text(
          'Kegiatan Dan Kontribusi:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(organization.description, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 24),
        // Edit and Delete buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
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
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Use switch on runtimeType to determine which layout to render
    switch (item.runtimeType) {
      case ProjectPortfolio:
        return _buildProjectDetail();
      case CertificatePortfolio:
        return _buildCertificateDetail(context);
      case OrganizationPortfolio:
        return _buildOrganizationDetail(context);
      default:
        return const Center(child: Text('Unknown portfolio type'));
    }
  }
}

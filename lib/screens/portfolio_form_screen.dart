import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import 'package:intl/intl.dart';

class PortfolioFormScreen extends StatefulWidget {
  final PortfolioItem? existingItem;

  const PortfolioFormScreen({super.key, this.existingItem});

  @override
  State<PortfolioFormScreen> createState() => _PortfolioFormScreenState();
}

class _PortfolioFormScreenState extends State<PortfolioFormScreen> {
  late bool isEditing;
  String _selectedCategory = 'Sertifikat';

  // Controllers for Certificate form
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _issuerController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  List<String> _skills = [];
  String? _certificateFile;

  // Controllers for Organization form
  final TextEditingController _orgTitleController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isEditing = widget.existingItem != null;

    if (isEditing) {
      // Pre-fill form with existing data
      final item = widget.existingItem!;

      if (item is CertificatePortfolio) {
        _selectedCategory = 'Sertifikat';
        _titleController.text = item.title;
        _issuerController.text = item.issuer;
        _startDateController.text = item.startDate;
        _endDateController.text = item.endDate;
        _skills = List.from(item.skills);
        _certificateFile = item.certificateFile;
      } else if (item is OrganizationPortfolio) {
        _selectedCategory = 'Organisasi';
        _orgTitleController.text = item.title;
        _positionController.text = item.position;
        _durationController.text = item.duration;
        _descriptionController.text = item.description;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _issuerController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _orgTitleController.dispose();
    _positionController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  void _handleSubmit() {
    final provider = Provider.of<PortfolioProvider>(context, listen: false);

    if (_selectedCategory == 'Sertifikat') {
      final certificate = CertificatePortfolio(
        id: isEditing
            ? widget.existingItem!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        issuer: _issuerController.text,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        skills: _skills,
        certificateFile: _certificateFile,
      );

      if (isEditing) {
        provider.updatePortfolio(certificate);
        Navigator.pop(context); // Back to detail
        Navigator.pop(context); // Back to list
      } else {
        provider.addPortfolio(certificate);
        Navigator.pop(context); // Back to list
      }
    } else if (_selectedCategory == 'Organisasi') {
      final organization = OrganizationPortfolio(
        id: isEditing
            ? widget.existingItem!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _orgTitleController.text,
        position: _positionController.text,
        duration: _durationController.text,
        description: _descriptionController.text,
      );

      if (isEditing) {
        provider.updatePortfolio(organization);
        Navigator.pop(context); // Back to detail
        Navigator.pop(context); // Back to list
      } else {
        provider.addPortfolio(organization);
        Navigator.pop(context); // Back to list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                const BackButton(color: Colors.black),
                const SizedBox(height: 16),
                // Title
                const Text(
                  'Add Portfolio',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                // Category Dropdown
                const Text(
                  'Kategori',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        'assets/logos/dropdown.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Sertifikat',
                      child: Text('Sertifikat'),
                    ),
                    DropdownMenuItem(
                      value: 'Organisasi',
                      child: Text('Organisasi'),
                    ),
                  ],
                  onChanged: isEditing
                      ? null // Disable dropdown when editing
                      : (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                ),
                const SizedBox(height: 24),
                // Render form based on category
                if (_selectedCategory == 'Sertifikat') _buildCertificateForm(),
                if (_selectedCategory == 'Organisasi') _buildOrganizationForm(),
                const SizedBox(height: 24),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isEditing ? 'Update' : 'Tambah',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text('Judul', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Contoh: IBM Certified AI Engineer',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Issuer
        const Text(
          'Penerbit Sertifikat',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _issuerController,
          decoration: InputDecoration(
            hintText: 'Contoh: Microsoft',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Date Range
        const Text(
          'Tanggal Berlaku',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: '09/10/2025',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/logos/calendar.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
                onTap: () => _selectDate(context, _startDateController),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('—', style: TextStyle(fontSize: 20)),
            ),
            Expanded(
              child: TextField(
                controller: _endDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: '09/10/2025',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/logos/calendar.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
                onTap: () => _selectDate(context, _endDateController),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Skills Input
        const Text(
          'Skill Yang Didapatkan',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SkillInputChipField(
          skills: _skills,
          onSkillsChanged: (skills) {
            setState(() {
              _skills = skills;
            });
          },
        ),
        const SizedBox(height: 16),
        // Certificate File Upload
        const Text(
          'Bukti Sertifikat',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            // Handle file upload
            setState(() {
              _certificateFile = 'uploaded_file.pdf';
            });
          },
          icon: SvgPicture.asset(
            'assets/logos/upload.svg',
            width: 20,
            height: 20,
          ),
          label: Text(
            _certificateFile ?? 'Upload File',
            style: const TextStyle(color: Colors.black),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text('Judul', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: _orgTitleController,
          decoration: InputDecoration(
            hintText: 'Contoh: Himpunan Mahasiswa Elektronika',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Position
        const Text(
          'Posisi',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _positionController,
          decoration: InputDecoration(
            hintText: 'Contoh: Ketua Divisi Teknologi',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Duration
        const Text(
          'Masa Jabatan',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _durationController,
          decoration: InputDecoration(
            hintText: 'Contoh: 1 Tahun 6 Bulan',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Description
        const Text(
          'Kegiatan & Kontribusi',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: '''Contoh:

1. Mengatur Jalannya Acara Greet & Meet Mas Amba Dengan Mahasiswa Himanika

2. Memberikan Kata Sambutan Pada Acara Pengajian Bahlil Dengan Tema "Menjawab Pertanyaan Munkar-Nakir Dengan Bantuan AI" ...''',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom SkillInputChipField Component
class SkillInputChipField extends StatefulWidget {
  final List<String> skills;
  final Function(List<String>) onSkillsChanged;

  const SkillInputChipField({
    super.key,
    required this.skills,
    required this.onSkillsChanged,
  });

  @override
  State<SkillInputChipField> createState() => _SkillInputChipFieldState();
}

class _SkillInputChipFieldState extends State<SkillInputChipField> {
  final TextEditingController _skillController = TextEditingController();

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    if (_skillController.text.isNotEmpty) {
      final updatedSkills = [...widget.skills, _skillController.text];
      widget.onSkillsChanged(updatedSkills);
      _skillController.clear();
    }
  }

  void _removeSkill(int index) {
    final updatedSkills = [...widget.skills];
    updatedSkills.removeAt(index);
    widget.onSkillsChanged(updatedSkills);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: _skillController,
          decoration: InputDecoration(
            hintText: 'Contoh: Leadership',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            suffixIcon: IconButton(
              icon: SvgPicture.asset(
                'assets/logos/addskills.svg',
                width: 20,
                height: 20,
              ),
              onPressed: _addSkill,
            ),
          ),
          onSubmitted: (_) => _addSkill(),
        ),
        const SizedBox(height: 12),
        // Chips display
        if (widget.skills.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.skills.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value),
                deleteIcon: SvgPicture.asset(
                  'assets/logos/close.svg',
                  width: 16,
                  height: 16,
                ),
                onDeleted: () => _removeSkill(entry.key),
                backgroundColor: const Color(0xFFE0E0E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

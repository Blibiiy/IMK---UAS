import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../providers/portfolio_provider.dart';
import '../providers/user_provider.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
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
  String? _certificateFile; // URL or filename
  File? _selectedFile; // The actual file to upload
  bool _isUploading = false;

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

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        // Validate file size (max 10MB)
        if (fileSize > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukuran file tidak boleh lebih dari 10 MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFile = file;
          _certificateFile = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadFileToStorage(String userId) async {
    if (_selectedFile == null) return _certificateFile;

    setState(() => _isUploading = true);

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(_selectedFile!.path);
      final fileName = 'certificate_${userId}_$timestamp$extension';
      final filePath = 'certificates/$userId/$fileName';

      final supabaseService = SupabaseService();
      final publicUrl = await supabaseService.uploadFile(
        file: _selectedFile!,
        bucket: 'portfolios',
        path: filePath,
      );

      return publicUrl;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _handleSubmit() async {
    final provider = Provider.of<PortfolioProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak ditemukan. Silakan login kembali.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (_selectedCategory == 'Sertifikat') {
        // Upload file if new file selected
        String? fileUrl = _certificateFile;
        if (_selectedFile != null) {
          fileUrl = await _uploadFileToStorage(userId);
        }

        final certificate = CertificatePortfolio(
          id: isEditing
              ? widget.existingItem!.id
              : DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          issuer: _issuerController.text,
          startDate: _startDateController.text,
          endDate: _endDateController.text,
          skills: _skills,
          certificateFile: fileUrl,
        );

        if (isEditing) {
          await provider.updatePortfolio(certificate);
          if (mounted) Navigator.pop(context); // Close loading
          if (mounted) Navigator.pop(context); // Back to detail
          if (mounted) Navigator.pop(context); // Back to list
        } else {
          await provider.addPortfolio(certificate, userId);
          if (mounted) Navigator.pop(context); // Close loading
          if (mounted) Navigator.pop(context); // Back to list
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
          await provider.updatePortfolio(organization);
          if (mounted) Navigator.pop(context); // Close loading
          if (mounted) Navigator.pop(context); // Back to detail
          if (mounted) Navigator.pop(context); // Back to list
        } else {
          await provider.addPortfolio(organization, userId);
          if (mounted) Navigator.pop(context); // Close loading
          if (mounted) Navigator.pop(context); // Back to list
        }
      }
    } catch (e) {
      // Close loading
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan portfolio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                icon: SvgPicture.asset(
                  'assets/logos/back.svg',
                  width: 24,
                  height: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              // Dynamic Title
              Text(
                isEditing ? 'Edit Portfolio' : 'Add Portfolio',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              // Category Dropdown
              Text(
                'Kategori',
                style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cs.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outline, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outline, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary, width: 2),
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
              const SizedBox(height: 32),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _handleSubmit,
                  icon: Icon(
                    isEditing
                        ? Icons.check_circle_outline
                        : Icons.add_circle_outline,
                    size: 20,
                  ),
                  label: Text(
                    _isUploading
                        ? 'Uploading...'
                        : isEditing
                        ? 'Update Portfolio'
                        : 'Tambah Portfolio',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    disabledBackgroundColor: cs.surfaceVariant,
                    disabledForegroundColor: cs.onSurfaceVariant,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateForm() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Judul',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Contoh: IBM Certified AI Engineer',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Issuer
        Text(
          'Penerbit Sertifikat',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _issuerController,
          decoration: InputDecoration(
            hintText: 'Contoh: Microsoft',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Date Range
        Text(
          'Tanggal Berlaku',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
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
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
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
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
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
        Text(
          'Skill Yang Didapatkan',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
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
        Text(
          'Bukti Sertifikat (Opsional)',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          'Format: PDF, JPG, PNG, GIF, WEBP (Max 10 MB)',
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(8),
            color: cs.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickFile,
                icon: _isUploading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary,
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/logos/upload.svg',
                        width: 20,
                        height: 20,
                      ),
                label: Text(
                  _isUploading
                      ? 'Mengupload...'
                      : (_certificateFile != null
                            ? 'Ganti File'
                            : 'Pilih File'),
                  style: TextStyle(color: cs.onSurface),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cs.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              if (_certificateFile != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _certificateFile!.endsWith('.pdf')
                            ? Icons.picture_as_pdf
                            : Icons.image,
                        size: 20,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedFile != null
                              ? _certificateFile!
                              : 'File sudah diupload',
                          style: TextStyle(fontSize: 12, color: cs.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 18, color: cs.error),
                        onPressed: () {
                          setState(() {
                            _selectedFile = null;
                            _certificateFile = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizationForm() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Judul',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _orgTitleController,
          decoration: InputDecoration(
            hintText: 'Contoh: Himpunan Mahasiswa Elektronika',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Position
        Text(
          'Posisi',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _positionController,
          decoration: InputDecoration(
            hintText: 'Contoh: Ketua Divisi Teknologi',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Duration
        Text(
          'Masa Jabatan',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _durationController,
          decoration: InputDecoration(
            hintText: 'Contoh: 1 Tahun 6 Bulan',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Description
        Text(
          'Kegiatan & Kontribusi',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: '''Contoh:

1. Mengatur Jalannya Acara Greet & Meet Mas Amba Dengan Mahasiswa Himanika

2. Memberikan Kata Sambutan Pada Acara Pengajian Bahlil Dengan Tema "Menjawab Pertanyaan Munkar-Nakir Dengan Bantuan AI" ...''',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
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
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: _skillController,
          decoration: InputDecoration(
            hintText: 'Contoh: Leadership',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
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
                backgroundColor: cs.surfaceVariant,
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

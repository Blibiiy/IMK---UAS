import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/project_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/success_dialog.dart';

class LecturerAddProjectScreen extends StatefulWidget {
  const LecturerAddProjectScreen({super.key});

  @override
  State<LecturerAddProjectScreen> createState() =>
      _LecturerAddProjectScreenState();
}

class _LecturerAddProjectScreenState extends State<LecturerAddProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _participantsController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<String> _requirements = [];

  @override
  void dispose() {
    _titleController.dispose();
    _deadlineController.dispose();
    _participantsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      _deadlineController.text = DateFormat('dd MMMM yyyy').format(picked);
    }
  }

  InputDecoration _outlineInputDecoration({
    String? hintText,
    Widget? suffixIcon,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      // Placeholder dengan warna lebih transparan
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontWeight: FontWeight.w300,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      suffixIcon: suffixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: suffixIcon,
            )
          : null,
      suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
      suffixText: suffixText,
      suffixStyle: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Future<void> _onPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_requirements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal 1 persyaratan project'),
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
      // Ambil nama dosen yang sedang login
      final currentUser = context.read<UserProvider>().currentUser;
      final lecturerName = currentUser?.fullName ?? 'Dosen Pembimbing';

      await context.read<ProjectProvider>().addProject(
        title: _titleController.text.trim(),
        deadline: _deadlineController.text.trim(),
        participants: _participantsController.text.trim(),
        description: _descriptionController.text.trim(),
        requirements: _requirements,
        lecturerFullName: lecturerName,
      );

      // Close loading
      if (mounted) Navigator.of(context).pop();

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => SuccessDialog(
            message: 'Project Berhasil Di posting !',
            onClose: () {
              // kembali ke dashboard dosen
              Navigator.of(context).pop();
            },
          ),
        );
      }
    } catch (e) {
      // Close loading
      if (mounted) Navigator.of(context).pop();

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memposting project: $e'),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/logos/back.svg',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add Project',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 24),

                // Nama Project
                Text(
                  'Nama Project',
                  style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: _outlineInputDecoration(
                    hintText: 'Contoh: Aplikasi Pendeteksi Plat Nomor',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama project wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                // Tanggal Deadline
                Text(
                  'Tanggal Deadline',
                  style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _deadlineController,
                  readOnly: true,
                  decoration: _outlineInputDecoration(
                    hintText: 'Pilih Tanggal Deadline',
                    suffixIcon: SvgPicture.asset(
                      'assets/logos/calendar.svg',
                      width: 22,
                      height: 22,
                    ),
                  ),
                  onTap: _pickDeadline,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Tanggal wajib dipilih'
                      : null,
                ),
                const SizedBox(height: 16),

                // Jumlah Partisipan
                Text(
                  'Jumlah Partisipan',
                  style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _participantsController,
                  decoration: _outlineInputDecoration(
                    hintText: 'Contoh: 5',
                    suffixText: 'Partisipan',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Jumlah partisipan wajib diisi';
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0)
                      return 'Jumlah partisipan harus angka > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Persyaratan Project
                Text(
                  'Persyaratan Project',
                  style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                RequirementInputChipField(
                  requirements: _requirements,
                  onRequirementsChanged: (requirements) {
                    setState(() {
                      _requirements = requirements;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Detail Project
                Text(
                  'Detail Project',
                  style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 10,
                  decoration: _outlineInputDecoration(
                    hintText:
                        'Contoh: Project ini bertujuan untuk mengembangkan aplikasi mobile yang dapat mendeteksi dan membaca plat nomor kendaraan secara otomatis menggunakan teknologi computer vision...',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Detail project wajib diisi'
                      : null,
                ),
                const SizedBox(height: 28),

                // Tombol Post
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: _onPost,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
}

// Custom RequirementInputChipField Component
class RequirementInputChipField extends StatefulWidget {
  final List<String> requirements;
  final Function(List<String>) onRequirementsChanged;

  const RequirementInputChipField({
    super.key,
    required this.requirements,
    required this.onRequirementsChanged,
  });

  @override
  State<RequirementInputChipField> createState() =>
      _RequirementInputChipFieldState();
}

class _RequirementInputChipFieldState extends State<RequirementInputChipField> {
  final TextEditingController _requirementController = TextEditingController();

  @override
  void dispose() {
    _requirementController.dispose();
    super.dispose();
  }

  void _addRequirement() {
    if (_requirementController.text.isNotEmpty) {
      final updatedRequirements = [
        ...widget.requirements,
        _requirementController.text,
      ];
      widget.onRequirementsChanged(updatedRequirements);
      _requirementController.clear();
    }
  }

  void _removeRequirement(int index) {
    final updatedRequirements = [...widget.requirements];
    updatedRequirements.removeAt(index);
    widget.onRequirementsChanged(updatedRequirements);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: _requirementController,
          decoration: InputDecoration(
            hintText: 'Contoh: Mampu bekerja dalam tim',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
              onPressed: _addRequirement,
            ),
          ),
          onSubmitted: (_) => _addRequirement(),
        ),
        const SizedBox(height: 12),
        // Chips display
        if (widget.requirements.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.requirements.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value),
                deleteIcon: SvgPicture.asset(
                  'assets/logos/close.svg',
                  width: 16,
                  height: 16,
                ),
                onDeleted: () => _removeRequirement(entry.key),
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

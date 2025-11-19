import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/project_provider.dart';
import '../widgets/success_dialog.dart';

class LecturerAddProjectScreen extends StatefulWidget {
  const LecturerAddProjectScreen({super.key});

  @override
  State<LecturerAddProjectScreen> createState() => _LecturerAddProjectScreenState();
}

class _LecturerAddProjectScreenState extends State<LecturerAddProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _participantsController = TextEditingController();
  final _requirementsController = TextEditingController(); // baru
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _deadlineController.dispose();
    _participantsController.dispose();
    _requirementsController.dispose();
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
      // Placeholder normal
      hintStyle: TextStyle(
        color: Colors.grey[600],
        fontWeight: FontWeight.w400,
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

  List<String> _requirementsToList(String raw) {
    // Pecah per baris, bersihkan yang kosong
    return raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _onPost() {
    if (!_formKey.currentState!.validate()) return;

    final requirementsList = _requirementsToList(_requirementsController.text);

    context.read<ProjectProvider>().addProject(
          title: _titleController.text.trim(),
          deadline: _deadlineController.text.trim(),
          participants: _participantsController.text.trim(),
          description: _descriptionController.text.trim(),
          requirements: requirementsList,
          // lecturerFullName opsional (default placeholder)
        );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  icon: SvgPicture.asset('assets/logos/back.svg', width: 24, height: 24),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add Project',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Nama Project
                TextFormField(
                  controller: _titleController,
                  decoration: _outlineInputDecoration(hintText: 'Nama Project'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama project wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Tanggal
                TextFormField(
                  controller: _deadlineController,
                  readOnly: true,
                  decoration: _outlineInputDecoration(
                    hintText: 'Tanggal',
                    suffixIcon: SvgPicture.asset('assets/logos/calendar.svg', width: 22, height: 22),
                  ),
                  onTap: _pickDeadline,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Tanggal wajib dipilih' : null,
                ),
                const SizedBox(height: 16),

                // Jumlah Partisipan (angka + label "Partisipan" di kanan)
                TextFormField(
                  controller: _participantsController,
                  decoration: _outlineInputDecoration(
                    hintText: 'Jumlah Partisipan',
                    suffixText: 'Partisipan',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Jumlah partisipan wajib diisi';
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Jumlah partisipan harus angka > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Persyaratan Project (multiline)
                TextFormField(
                  controller: _requirementsController,
                  maxLines: 6,
                  decoration: _outlineInputDecoration(hintText: 'Persyaratan Project...'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Persyaratan project wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Detail Project...
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 10,
                  decoration: _outlineInputDecoration(hintText: 'Detail Project...'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Detail project wajib diisi' : null,
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
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
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
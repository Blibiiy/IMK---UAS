import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/project_provider.dart';

class LecturerEditProjectScreen extends StatefulWidget {
  final String projectId;

  const LecturerEditProjectScreen({super.key, required this.projectId});

  @override
  State<LecturerEditProjectScreen> createState() => _LecturerEditProjectScreenState();
}

class _LecturerEditProjectScreenState extends State<LecturerEditProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _participantsController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _descriptionController = TextEditingController();

  Project? _project;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProjectProvider>();
    _project = provider.getProjectById(widget.projectId);
    if (_project != null) {
      _titleController.text = _project!.title;
      _deadlineController.text = _project!.deadline;
      _participantsController.text = _project!.participants;
      _requirementsController.text = _project!.requirements.join('\n');
      _descriptionController.text = _project!.description;
    }
  }

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
    return raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _onUpdate() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProjectProvider>().updateProject(
          id: widget.projectId,
          title: _titleController.text.trim(),
          deadline: _deadlineController.text.trim(),
          participants: _participantsController.text.trim(),
          description: _descriptionController.text.trim(),
          requirements: _requirementsToList(_requirementsController.text),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project berhasil diperbarui.')),
    );
    Navigator.pop(context); // kembali ke detail, data otomatis ter-update via provider
  }

  @override
  Widget build(BuildContext context) {
    if (_project == null) {
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
                  'Edit Project',
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

                // Jumlah Partisipan
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

                // Persyaratan Project
                TextFormField(
                  controller: _requirementsController,
                  maxLines: 6,
                  decoration: _outlineInputDecoration(hintText: 'Persyaratan Project...'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Persyaratan project wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Detail Project
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 10,
                  decoration: _outlineInputDecoration(hintText: 'Detail Project...'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Detail project wajib diisi' : null,
                ),
                const SizedBox(height: 28),

                // Tombol Update
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: _onUpdate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    ),
                    child: const Text(
                      'Update',
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
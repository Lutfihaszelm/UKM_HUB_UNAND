import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/oprec_post.dart';
import '../repositories/oprec_repository.dart';

class OprecFormScreen extends StatefulWidget {
  final OprecPost post;
  final OprecRepository repository;

  const OprecFormScreen({
    super.key,
    required this.post,
    required this.repository,
  });

  @override
  State<OprecFormScreen> createState() => _OprecFormScreenState();
}

class _OprecFormScreenState extends State<OprecFormScreen> {
  static const _maxFileBytes = 2 * 1024 * 1024;
  static const _allowedExtensions = ['pdf', 'jpg', 'png'];

  final _formKey = GlobalKey<FormState>();
  final _motivationController = TextEditingController();
  final _nimController = TextEditingController();
  final _nameController = TextEditingController();
  PlatformFile? _pickedFile;
  bool _isSubmitting = false;

  bool get isFormValid => 
  _validateName(_nameController.text) == null &&
  _validateNim(_nimController.text) == null &&
  _validateMotivation(_motivationController.text) == null;

  @override
  void dispose() {
    _motivationController.dispose();
    _nimController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String? _validateNim(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'NIM wajib diisi';
    if (!RegExp(r'^\d{10}$').hasMatch(text)) {
      return 'NIM harus 10 digit angka';
    }
    return null; // null artinya valid
  }


  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nama wajib diisi';
    if (text.length < 3) {
      return 'Minimal 3 karakter (sekarang ${text.length})';
    }
    return null; // null artinya valid
  }

  String? _validateMotivation(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Motivasi wajib diisi';
    if (text.length < 20) {
      return 'Minimal 20 karakter (sekarang ${text.length})';
    }
    return null; // null artinya valid
  }

  String? _validateFile(PlatformFile? file) {
    if (file == null) return 'File wajib diunggah';
    final size = file.lengthSync();
    if (size != null && size > _maxFileBytes) {
      return 'Ukuran file maksimal 2 MB';
    }
    final extension = file.extension?.toLowerCase();
    if (extension == null || !_allowedExtensions.contains(extension)) {
      return 'Format file harus PDF, JPG, atau PNG';
    }
    return null; // null artinya valid
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return 'Ukuran tidak diketahui';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickFile(FormFieldState<PlatformFile> field) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );
    if (file == null) return; //kalau batal pilih file, tidak perlu update state
    
    setState(() => _pickedFile = file);
    field.didChange(file); // update state field agar validasi dijalankan
  }

   void _removeFile(FormFieldState<PlatformFile> field) {
    setState(() => _pickedFile = null);
    field.didChange(null);
  }

  void _showMessage(String text, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _submit() async {
    // 1. Validasi dulu
    if (!_formKey.currentState!.validate()) return;

    // 2. Mulai loading
    setState(() => _isSubmitting = true);

    try {
      // 3. Kirim lewat repository, maksimal menunggu 15 detik
      final registration = await widget.repository
          .submitRegistration(
            post: widget.post,
            motivation: _motivationController.text.trim(),
            file: _pickedFile!,
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      Navigator.pop(context, registration);
    } on RegistrationException catch (e) {
      if (!mounted) return;
      _showMessage(e.message, isError: true);
    } on TimeoutException {
      if (!mounted) return;
      _showMessage(
        'Server terlalu lama merespons. Coba lagi beberapa saat.',
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Terjadi kesalahan tak terduga. Coba lagi.', isError: true);
    } finally {
      // 4. Loading selalu berhenti, sukses maupun gagal
      if (mounted) setState(() => _isSubmitting = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pendaftaran', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        shadowColor: Color.fromRGBO(44, 110, 73, 0.5),),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ringkasan oprec (data yang dikirim dari screen detail)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ], 
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mendaftar ke:',
                    style: textTheme.bodySmall?.copyWith(color: colors.outline),
                  ),
                const SizedBox(height: 4),
                // Nama UKM + Logo
                  Row(
                    children: [
                      ClipOval(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: widget.post.logoUKM == null
                          ? Container(color: colors.outline)
                          : Image.asset(
                              widget.post.logoUKM!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: colors.outline),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.post.ukmName,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                    ]),                  
                  const SizedBox(height: 2),
                  Text(widget.post.title, style: textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Form
            Form(
              key: _formKey,
              onChanged: () => setState(() {}), // untuk memicu rebuild saat validasi berubah
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    maxLines: 1,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _validateName,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      hintText: 'Nama lengkap sesuai KTP / KTM',),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nimController,
                    maxLines: 1,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _validateNim,
                    decoration: const InputDecoration(
                      labelText: 'NIM',
                      hintText: 'Contoh : 2411522010',),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _motivationController,
                    maxLines: 5,
                    maxLength: 300,
                    buildCounter: (context,
                            {required currentLength,
                            required isFocused,
                            required maxLength}) =>
                        Text(
                          '$currentLength / $maxLength',
                          style: textTheme.bodySmall
                              ?.copyWith(color: colors.outline),
                        ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _validateMotivation,
                    decoration: const InputDecoration(
                      labelText: 'Motivasi',
                      hintText: 'Kenapa kamu ingin bergabung?',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FormField<PlatformFile>(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (_) => _validateFile(_pickedFile),
                    builder: (field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unggah File', style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _pickFile(field),
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Pilih File'),
                            ),
                            const SizedBox(width: 12),
                            if (_pickedFile != null)
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${_pickedFile!.name} (${_formatSize(_pickedFile!.lengthSync())})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => _removeFile(field),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              field.errorText!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.error,
                              ),
                            ),
                          ),
                      ],
                    )
                  ),
                 
                  const SizedBox(height: 24),

                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: (isFormValid && !_isSubmitting) ? _submit : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('Kirim'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
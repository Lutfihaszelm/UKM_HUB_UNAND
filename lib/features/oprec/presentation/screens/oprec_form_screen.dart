import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/oprec_post.dart';
import '../../data/oprec_repository.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/validators.dart';

/// Berkas yang sudah dipilih untuk satu slot, beserta hasil pengecekannya.
class _PickedFile {
  final XFile file;
  final int size;
  final Uint8List? preview; // isi gambar untuk thumbnail; null untuk PDF
  final String? error; // null artinya valid

  const _PickedFile({
    required this.file,
    required this.size,
    this.preview,
    this.error,
  });
}

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

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _prodiController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _motivationController = TextEditingController();
  final _imagePicker = ImagePicker();

  /// Berkas terpilih, berkunci [RequiredFile.id].
  final Map<String, _PickedFile> _picked = {};
  bool _isSubmitting = false;

  List<RequiredFile> get _slots => widget.post.requiredFiles;

  bool get _isFormValid =>
      Validators.name(_nameController.text) == null &&
      Validators.nim(_nimController.text) == null &&
      Validators.prodi(_prodiController.text) == null &&
      Validators.whatsapp(_whatsappController.text) == null &&
      Validators.motivation(_motivationController.text) == null &&
      _slots.every((slot) => _validateSlot(slot) == null);

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _whatsappController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  String? _validateSlot(RequiredFile slot) {
    final picked = _picked[slot.id];
    if (picked == null) return slot.isRequired ? 'Berkas wajib diunggah' : null;
    return picked.error;
  }

  static String _extensionOf(String name) =>
      name.contains('.') ? name.split('.').last.toLowerCase() : '';

  Future<void> _pickFromFiles(
    RequiredFile slot,
    FormFieldState<void> field,
  ) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: slot.accept.extensions,
    );
    if (file == null) return; // batal pilih file, tidak perlu update state
    await _setFile(slot, field, file.xFile);
  }

  /// Fitur device: kamera, untuk slot yang menerima gambar.
  Future<void> _pickFromCamera(
    RequiredFile slot,
    FormFieldState<void> field,
  ) async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600, // foto kamera dikecilkan supaya muat di batas 2 MB
        imageQuality: 85,
      );
      if (photo == null) return;
      await _setFile(slot, field, photo);
    } on PlatformException {
      _showMessage('Kamera tidak bisa dibuka. Periksa izin kamera.',
          isError: true);
    }
  }

  Future<void> _setFile(
    RequiredFile slot,
    FormFieldState<void> field,
    XFile file,
  ) async {
    final size = await file.length();
    final extension = _extensionOf(file.name);
    String? error;
    if (!slot.accept.extensions.contains(extension)) {
      error = 'Berkas harus ${slot.accept.label}';
    } else if (size > _maxFileBytes) {
      error = 'Ukuran berkas maksimal 2 MB';
    }
    final isImage =
        error == null && FileAccept.image.extensions.contains(extension);
    final preview = isImage ? await file.readAsBytes() : null;

    if (!mounted) return;
    setState(() => _picked[slot.id] = _PickedFile(
          file: file,
          size: size,
          preview: preview,
          error: error,
        ));
    field.didChange(null); // jalankan ulang validasi slot ini
  }

  void _removeFile(RequiredFile slot, FormFieldState<void> field) {
    setState(() => _picked.remove(slot.id));
    field.didChange(null);
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
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
            name: _nameController.text.trim(),
            nim: _nimController.text.trim(),
            prodi: _prodiController.text.trim(),
            whatsapp: _whatsappController.text.trim(),
            motivation: _motivationController.text.trim(),
            files: _picked.map((slotId, picked) => MapEntry(slotId, picked.file)),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      Navigator.pop(context, registration);
    } on RegistrationException catch (e) {
      _showMessage(e.message, isError: true);
    } on TimeoutException {
      _showMessage(
        'Server terlalu lama merespons. Coba lagi beberapa saat.',
        isError: true,
      );
    } catch (_) {
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
      body: SafeArea(
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}), // rebuild saat validasi berubah
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 32),
                  tooltip: 'Kembali',
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
              Text(
                'Formulir Pendaftaran',
                textAlign: TextAlign.center,
                style: textTheme.displaySmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: 'Nama',
                child: TextFormField(
                  controller: _nameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Nama lengkap sesuai KTM',
                  ),
                ),
              ),
              _LabeledField(
                label: 'NIM',
                child: TextFormField(
                  controller: _nimController,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.nim,
                  decoration: const InputDecoration(
                    hintText: 'Contoh : 2411522010',
                  ),
                ),
              ),
              _LabeledField(
                label: 'Program Studi',
                child: TextFormField(
                  controller: _prodiController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.prodi,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Contoh : Sistem Informasi',
                  ),
                ),
              ),
              _LabeledField(
                label: 'No.WhatsApp',
                child: TextFormField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.whatsapp,
                  decoration: const InputDecoration(
                    hintText: 'Contoh : 081234567890',
                  ),
                ),
              ),
              _LabeledField(
                label: 'Apa Motivasi kamu ingin bergabung?',
                child: TextFormField(
                  controller: _motivationController,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 1000,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.motivation,
                  decoration: const InputDecoration(
                    hintText: 'Ceritakan alasanmu, minimal 20 karakter',
                  ),
                ),
              ),
              for (final slot in _slots)
                _LabeledField(
                  label: slot.isRequired ? slot.label : '${slot.label} (opsional)',
                  child: _buildFileSlot(slot),
                ),
              const SizedBox(height: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.actionBlue,
                  foregroundColor: AppColors.textOnButton,
                  minimumSize: const Size.fromHeight(52),
                  shape: const StadiumBorder(),
                  textStyle: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                onPressed: (_isFormValid && !_isSubmitting) ? _submit : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text('KONFIRMASI'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Satu slot unggah berkas (fitur device: file picker dan kamera).
  Widget _buildFileSlot(RequiredFile slot) {
    return FormField<void>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (_) => _validateSlot(slot),
      builder: (field) => _FileSlotCard(
        accept: slot.accept,
        picked: _picked[slot.id],
        // Pesan "wajib" baru tampil setelah user mencoba mengirim.
        errorText: field.errorText,
        onPickFile: () => _pickFromFiles(slot, field),
        onCamera:
            slot.accept.allowsCamera ? () => _pickFromCamera(slot, field) : null,
        // Slot wajib cukup diganti dengan memilih ulang; desain tidak punya
        // tombol hapus, jadi tombol ini hanya untuk slot opsional.
        onRemove: slot.isRequired ? null : () => _removeFile(slot, field),
      ),
    );
  }
}

// =====================================================================
// Widget-widget kecil penyusun form
// =====================================================================

/// Label tebal di atas field, sesuai desain.
class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

/// Kartu slot berkas: thumbnail, nama + status, tombol kamera, Pilih File.
class _FileSlotCard extends StatelessWidget {
  final FileAccept accept;
  final _PickedFile? picked;
  final String? errorText;
  final VoidCallback onPickFile;
  final VoidCallback? onCamera;
  final VoidCallback? onRemove;

  const _FileSlotCard({
    required this.accept,
    required this.picked,
    required this.errorText,
    required this.onPickFile,
    required this.onCamera,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final error = errorText ?? picked?.error;

    final status = error != null
        ? Text(error,
            style: textTheme.bodySmall?.copyWith(
                color: colors.error, fontStyle: FontStyle.italic))
        : Text(
            picked == null ? 'Format ${accept.label}, maks 2 MB' : 'Siap dikirim',
            style: textTheme.bodySmall?.copyWith(
              color: picked == null ? colors.outline : colors.primary,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.oprecFileCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.primary.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _Thumbnail(picked: picked),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  picked?.file.name ?? 'Belum ada berkas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                status,
              ],
            ),
          ),
          if (picked != null && onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              tooltip: 'Hapus berkas',
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
            ),
          if (onCamera != null) ...[
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              tooltip: 'Ambil foto',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.oprecCameraButton,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(44, 44),
              ),
              onPressed: onCamera,
            ),
            const SizedBox(width: 6),
          ],
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onPickFile,
            icon: const Icon(Icons.upload, size: 20),
            label: const Text('Pilih File'),
          ),
        ],
      ),
    );
  }
}

/// Pratinjau gambar terpilih; ikon untuk PDF atau slot kosong.
class _Thumbnail extends StatelessWidget {
  final _PickedFile? picked;
  const _Thumbnail({required this.picked});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final preview = picked?.preview;
    final icon = picked == null
        ? Icons.insert_drive_file_outlined
        : Icons.picture_as_pdf_outlined;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 48,
        color: Colors.white,
        child: preview != null
            ? Image.memory(preview, fit: BoxFit.cover)
            : Icon(icon, color: colors.outline),
      ),
    );
  }
}

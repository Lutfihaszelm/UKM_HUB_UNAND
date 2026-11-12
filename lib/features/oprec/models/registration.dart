/// Status pendaftaran oprec. Sebelumnya berupa String bebas ('Menunggu'),
/// sekarang enum agar tidak ada salah ketik dan mudah dipakai untuk notifikasi.
/// Nama enum sama persis dengan nilai `registration_status` di server.
enum RegistrationStatus {
  menunggu('Menunggu'),
  seleksi('Seleksi Berkas'),
  wawancara('Wawancara'),
  diterima('Diterima'),
  ditolak('Ditolak'),
  dibatalkan('Dibatalkan');

  final String label;
  const RegistrationStatus(this.label);

  /// Ubah string dari server (mis. 'seleksi') ke enum.
  static RegistrationStatus fromServer(String value) =>
      RegistrationStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () =>
            throw FormatException('Status pendaftaran tidak dikenal: $value'),
      );
}

/// Satu baris riwayat status (`oprec_status_history`), termasuk saat dibuat.
class StatusChange {
  final RegistrationStatus? fromStatus; // null untuk baris pertama
  final RegistrationStatus toStatus;
  final String? note;
  final String changedBy; // 'mahasiswa' atau 'admin'
  final DateTime changedAt;

  const StatusChange({
    required this.fromStatus,
    required this.toStatus,
    this.note,
    required this.changedBy,
    required this.changedAt,
  });

  factory StatusChange.fromJson(Map<String, dynamic> json) {
    final from = json['from_status'] as String?;
    return StatusChange(
      fromStatus: from == null ? null : RegistrationStatus.fromServer(from),
      toStatus: RegistrationStatus.fromServer(json['to_status'] as String),
      note: json['note'] as String?,
      changedBy: json['changed_by'] as String,
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }
}

/// Satu berkas yang sudah dikirim untuk satu slot [RequiredFile].
class RegistrationFile {
  final String requiredFileId;
  final String label; // mis. 'Pas Foto', disalin dari slot oprec
  final String name;
  final int sizeBytes;
  final String mime;

  const RegistrationFile({
    required this.requiredFileId,
    required this.label,
    required this.name,
    required this.sizeBytes,
    required this.mime,
  });

  factory RegistrationFile.fromJson(Map<String, dynamic> json) =>
      RegistrationFile(
        requiredFileId: json['required_file_id'] as String,
        label: json['label'] as String,
        name: json['name'] as String,
        sizeBytes: json['size_bytes'] as int,
        mime: json['mime'] as String,
      );
}

class Registration {
  final String id;
  final String postId;
  final String name;
  final String nim;
  final String prodi;
  final String whatsapp;
  final String motivation;
  final List<RegistrationFile> files;
  final RegistrationStatus status;

  /// Boleh edit / batal: status masih menunggu dan oprec belum ditutup.
  /// Dihitung server, jadi layar cukup membaca nilai ini.
  final bool canModify;
  final DateTime createdAt; // submitted_at
  final DateTime updatedAt;
  final DateTime? cancelledAt;

  /// Kosong pada daftar; terisi pada detail (GET /registrations/{id}).
  final List<StatusChange> history;

  const Registration({
    required this.id,
    required this.postId,
    required this.name,
    required this.nim,
    required this.prodi,
    required this.whatsapp,
    required this.motivation,
    required this.files,
    required this.status,
    required this.canModify,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
    this.history = const [],
  });

  factory Registration.fromJson(Map<String, dynamic> json) {
    final cancelledAt = json['cancelled_at'] as String?;
    final history = json['history'] as List<dynamic>? ?? const [];
    final files = json['files'] as List<dynamic>;
    return Registration(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      name: json['full_name'] as String,
      nim: json['nim'] as String,
      prodi: json['prodi'] as String,
      whatsapp: json['whatsapp'] as String,
      motivation: json['motivation'] as String,
      files: files
          .map((e) => RegistrationFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: RegistrationStatus.fromServer(json['status'] as String),
      canModify: json['can_modify'] as bool,
      createdAt: DateTime.parse(json['submitted_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      cancelledAt: cancelledAt == null ? null : DateTime.parse(cancelledAt),
      history: history
          .map((e) => StatusChange.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Registration copyWith({
    String? name,
    String? nim,
    String? prodi,
    String? whatsapp,
    String? motivation,
    List<RegistrationFile>? files,
    RegistrationStatus? status,
    bool? canModify,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    List<StatusChange>? history,
  }) {
    return Registration(
      id: id,
      postId: postId,
      name: name ?? this.name,
      nim: nim ?? this.nim,
      prodi: prodi ?? this.prodi,
      whatsapp: whatsapp ?? this.whatsapp,
      motivation: motivation ?? this.motivation,
      files: files ?? this.files,
      status: status ?? this.status,
      canModify: canModify ?? this.canModify,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      history: history ?? this.history,
    );
  }
}

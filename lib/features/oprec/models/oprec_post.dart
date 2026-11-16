/// Jenis berkas yang diterima satu slot unggah.
enum FileAccept {
  image(['jpg', 'jpeg', 'png'], 'JPG atau PNG'),
  pdf(['pdf'], 'PDF'),
  any(['pdf', 'jpg', 'jpeg', 'png'], 'PDF, JPG, atau PNG');

  final List<String> extensions;
  final String label;
  const FileAccept(this.extensions, this.label);

  /// Slot gambar boleh diisi langsung dari kamera.
  bool get allowsCamera => this != FileAccept.pdf;

  static FileAccept fromServer(String value) => FileAccept.values.firstWhere(
        (accept) => accept.name == value,
        orElse: () => throw FormatException('Jenis berkas tidak dikenal: $value'),
      );
}

/// Satu berkas yang diminta oprec (mis. Pas Foto, KTM). Ditentukan admin
/// per oprec; form menampilkan satu slot unggah untuk tiap item.
class RequiredFile {
  final String id;
  final String label;
  final FileAccept accept;
  final bool isRequired;

  const RequiredFile({
    required this.id,
    required this.label,
    required this.accept,
    this.isRequired = true,
  });

  factory RequiredFile.fromJson(Map<String, dynamic> json) => RequiredFile(
        id: json['id'] as String,
        label: json['label'] as String,
        accept: FileAccept.fromServer(json['accept'] as String),
        isRequired: json['is_required'] as bool,
      );
}

class OprecPost {
  final String id;
  final String ukmName;
  final String title;
  final String description;
  final DateTime closeDate;
  final String? logoUKM;
  final String? posterAsset;
  final List<String> requirements; // kartu Syarat Pendaftaran
  final List<RequiredFile> requiredFiles; // kartu Berkas yang diunggah
  final List<String> terms; // kartu Syarat dan Ketentuan Berlaku

  const OprecPost({
    required this.id,
    required this.ukmName,
    required this.title,
    required this.description,
    required this.closeDate,
    required this.logoUKM,
    this.posterAsset,
    this.requirements = const [],
    this.requiredFiles = const [],
    this.terms = const [],
  });

  bool get isClosed => DateTime.now().isAfter(closeDate);
}

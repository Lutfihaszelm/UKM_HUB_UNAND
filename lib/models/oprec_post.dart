class OprecPost {
  final String id;
  final String ukmName;
  final String title;
  final String description;
  final DateTime closeDate;
  final String? logoUKM;
  final String? posterAsset;

  const OprecPost({
    required this.id,
    required this.ukmName,
    required this.title,
    required this.description,
    required this.closeDate,
    required this.logoUKM,
    this.posterAsset,
  });

  bool get isClosed => DateTime.now().isAfter(closeDate);
}
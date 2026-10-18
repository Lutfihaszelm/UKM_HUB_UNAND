class Registration {
  final String id;  
  final String postId;
  final String motivation;
  final String fileName;
  final String status;
  final DateTime createdAt;

  const Registration({
    required this.id,
    required this.postId,
    required this.motivation,
    required this.fileName,
    required this.status,
    required this.createdAt,
  });
}
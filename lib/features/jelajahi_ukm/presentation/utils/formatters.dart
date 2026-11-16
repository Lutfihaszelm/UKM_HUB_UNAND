const List<String> _shortMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

const List<String> _longMonths = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String formatPostDate(DateTime date) {
  return '${date.day} ${_shortMonths[date.month - 1]} ${date.year}';
}

String formatLongDate(DateTime date) {
  return '${date.day} ${_longMonths[date.month - 1]} ${date.year}';
}

String formatRelativeTime(DateTime date, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final difference = reference.difference(date);

  if (difference.inMinutes < 1) return 'Baru saja';
  if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
  if (difference.inHours < 24) return '${difference.inHours} jam lalu';
  if (difference.inDays == 1) return 'Kemarin';
  if (difference.inDays < 7) return '${difference.inDays} hari lalu';
  return formatPostDate(date);
}

String formatCount(int value) {
  if (value < 1000) return '$value';
  final thousands = value / 1000;
  final text = thousands >= 10
      ? thousands.toStringAsFixed(0)
      : thousands.toStringAsFixed(1).replaceAll('.', ',');
  return '$text rb';
}

String formatFileSize(int bytes) {
  if (bytes <= 0) return 'Berkas';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

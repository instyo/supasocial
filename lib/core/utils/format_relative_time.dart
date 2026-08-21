String formatRelativeTime(DateTime? dateTime) {
  if (dateTime == null) return '';

  final now = DateTime.now();
  final local = dateTime.toLocal();
  final diff = now.difference(local);

  if (diff.isNegative || diff.inSeconds < 60) {
    return 'just now';
  }

  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return m == 1 ? '1 minute ago' : '$m minutes ago';
  }

  if (diff.inHours < 24) {
    final h = diff.inHours;
    return h == 1 ? '1 hour ago' : '$h hours ago';
  }

  if (diff.inDays < 7) {
    final d = diff.inDays;
    return d == 1 ? '1 day ago' : '$d days ago';
  }

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final month = months[local.month - 1];
  if (local.year == now.year) {
    return '$month ${local.day}';
  }
  return '$month ${local.day}, ${local.year}';
}

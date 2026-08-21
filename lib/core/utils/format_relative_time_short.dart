String formatRelativeTimeShort(DateTime? dateTime) {
  if (dateTime == null) return '';

  final now = DateTime.now();
  final local = dateTime.toLocal();
  final diff = now.difference(local);

  if (diff.isNegative || diff.inSeconds < 60) {
    return 'just now';
  }

  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }

  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }

  if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
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

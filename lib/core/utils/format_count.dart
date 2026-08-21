String formatCount(int count) {
  if (count < 1000) return count.toString();

  if (count < 1000000) {
    final value = count / 1000;
    if (count % 1000 == 0) return '${value.toInt()}k';
    final fixed = value.toStringAsFixed(1);
    return fixed.endsWith('.0') ? '${value.toInt()}k' : '${fixed}k';
  }

  final value = count / 1000000;
  if (count % 1000000 == 0) return '${value.toInt()}M';
  final fixed = value.toStringAsFixed(1);
  return fixed.endsWith('.0') ? '${value.toInt()}M' : '${fixed}M';
}

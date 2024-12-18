String formatDuration(Duration duration) {
  int days = duration.inDays;
  int hours = duration.inHours.remainder(24);
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);

  List<String> parts = [];
  if (days > 0) parts.add("${days}D");
  if (hours > 0 || days > 0) parts.add("${hours}H");
  if (minutes > 0 || hours > 0 || days > 0) parts.add("${minutes}M");
  parts.add("${seconds}S");

  return parts.join(" ");
}

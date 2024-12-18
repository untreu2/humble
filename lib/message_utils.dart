String calculateMessage(Duration elapsedTime) {
  int hours = elapsedTime.inHours;
  if (hours >= 0 && hours < 2) return '🔥 Blood sugar rises (0h - 2h)';
  if (hours >= 2 && hours < 5) return '📉 Blood sugar falls (2h - 5h)';
  if (hours >= 5 && hours < 8) return '🔄 Blood sugar returns to normal (5h - 8h)';
  if (hours >= 8 && hours < 10) return '🕒 Switch into fasting mode (8h - 10h)';
  if (hours >= 10 && hours < 12) return '🔥 Turning into fat burning (10h - 12h)';
  if (hours >= 12 && hours < 18) return '🌟 Ketosis state (12h - 18h)';
  if (hours >= 18 && hours < 24) return '🔥 Fat burning mode starts (18h - 24h)';
  if (hours >= 24 && hours < 48) return '🔄 Autophagy starts (24h - 48h)';
  if (hours >= 48 && hours < 56) return '🚀 Growth hormone goes up (48h - 56h)';
  if (hours >= 56 && hours < 72) return '🎯 Sensitive to Insuline (56h - 72h)';
  if (hours >= 72) return '🛡️ Immune cells regenerate (72h - )';
  return '';
}

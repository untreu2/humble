String calculateMessage(Duration elapsedTime) {
  int hours = elapsedTime.inHours;

  if (hours >= 0 && hours < 2) {
    return 'Digesting your meal. Blood glucose rising, insulin working to transport nutrients.';
  }

  if (hours >= 2 && hours < 5) {
    return 'Digestion complete. Blood sugar normalizing, body still using meal energy.';
  }

  if (hours >= 5 && hours < 8) {
    return 'Normal glucose levels reached. Body preparing to use stored carbohydrates.';
  }

  if (hours >= 8 && hours < 10) {
    return 'True fasting begins! Using glycogen stores, insulin at lowest levels.';
  }

  if (hours >= 10 && hours < 12) {
    return 'Switching to fat energy. Glycogen depleting, fat breakdown accelerating.';
  }

  if (hours >= 12 && hours < 18) {
    return 'Ketosis achieved! Brain using ketones, mental clarity improving.';
  }

  if (hours >= 18 && hours < 24) {
    return 'Fat-burning machine mode! Deep ketosis, inflammation reducing.';
  }

  if (hours >= 24 && hours < 48) {
    return 'Autophagy activated! Cellular cleanup and renewal process started.';
  }

  if (hours >= 48 && hours < 56) {
    return 'HGH levels peaked! Muscle preservation, enhanced fat burning.';
  }

  if (hours >= 56 && hours < 72) {
    return 'Insulin sensitivity optimized! Peak metabolic flexibility achieved.';
  }

  if (hours >= 72) {
    return 'Immune system renewal! Old cells eliminated, new ones generating. Medical supervision recommended.';
  }

  return '';
}

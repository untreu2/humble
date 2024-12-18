import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

Future<void> saveLastMealTime(DateTime? time) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (time != null) {
    await prefs.setInt('lastMealTime', time.millisecondsSinceEpoch);
  } else {
    await prefs.remove('lastMealTime');
  }
}

Future<DateTime?> loadLastMealTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? storedTime = prefs.getInt('lastMealTime');
  if (storedTime != null) {
    return DateTime.fromMillisecondsSinceEpoch(storedTime);
  }
  return null;
}

Future<void> saveFastDurations(List<Duration> durations) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> durationStrings =
      durations.map((duration) => duration.inSeconds.toString()).toList();
  await prefs.setStringList('fastDurations', durationStrings);
}

Future<List<Duration>> loadFastDurations() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? storedDurations = prefs.getStringList('fastDurations');
  if (storedDurations != null) {
    return storedDurations
        .map((duration) => Duration(seconds: int.parse(duration)))
        .toList();
  }
  return [];
}

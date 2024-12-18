import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLastMealTime(DateTime? time) async {
  final prefs = await SharedPreferences.getInstance();
  if (time != null) {
    prefs.setString('lastMealTime', time.toIso8601String());
  } else {
    prefs.remove('lastMealTime');
  }
}

Future<DateTime?> loadLastMealTime() async {
  final prefs = await SharedPreferences.getInstance();
  String? timeString = prefs.getString('lastMealTime');
  if (timeString != null) {
    return DateTime.parse(timeString);
  }
  return null;
}

Future<void> saveFastDurations(List<Duration> durations) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> durationsString = durations.map((d) => d.inSeconds.toString()).toList();
  prefs.setStringList('fastDurations', durationsString);
}

Future<List<Duration>> loadFastDurations() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? durationsString = prefs.getStringList('fastDurations');
  if (durationsString != null) {
    return durationsString.map((s) => Duration(seconds: int.parse(s))).toList();
  }
  return [];
}

Future<void> saveSelectedFastingGoal(Duration? goal) async {
  final prefs = await SharedPreferences.getInstance();
  if (goal != null) {
    prefs.setInt('selectedFastingGoal', goal.inSeconds);
  } else {
    prefs.remove('selectedFastingGoal');
  }
}

Future<Duration?> loadSelectedFastingGoal() async {
  final prefs = await SharedPreferences.getInstance();
  int? goalSeconds = prefs.getInt('selectedFastingGoal');
  if (goalSeconds != null) {
    return Duration(seconds: goalSeconds);
  }
  return null;
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(Humble());
}

class Humble extends StatefulWidget {
  @override
  _HumbleState createState() => _HumbleState();
}

class _HumbleState extends State<Humble> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Humble',
      theme: _isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: FastingScreen(toggleDarkMode: _toggleDarkMode),
    );
  }

ThemeData _buildLightTheme() {
  return ThemeData.light().copyWith(
    scaffoldBackgroundColor: Color(0xFFFBF1C7),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF458588),
      secondary: Color(0xFFB16286), 
      surface: Color(0xFFFBF1C7), 
      error: Color(0xFFCC241D),
      onPrimary: Color(0xFFFBF1C7), 
      onSecondary: Color(0xFFFBF1C7),
      onSurface: Color(0xFF282828), 
      onError: Color(0xFFFBF1C7),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF458588),
        foregroundColor: Color(0xFFFBF1C7),
      ),
    ),
  );
}

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.white,
        surface: Colors.black,
        error: Colors.white,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onError: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _saveThemePreference();
    _applyTheme();
  }

  void _applyTheme() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: _isDarkMode ? Colors.black : Colors.white,
      systemNavigationBarIconBrightness:
          _isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  void _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDarkMode = prefs.getBool('isDarkMode');
    if (isDarkMode != null) {
      setState(() {
        _isDarkMode = isDarkMode;
      });
      _applyTheme();
    }
  }
}

class FastingScreen extends StatefulWidget {
  final VoidCallback toggleDarkMode;

  const FastingScreen({required this.toggleDarkMode});

  @override
  _FastingScreenState createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen> {
  DateTime? _lastMealTime;
  late Timer _timer;
  Duration _elapsedTime = Duration(seconds: 0);
  bool _timerRunning = false;
  List<Duration> _fastDurations = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), _updateElapsedTime);
    _loadLastMealTime();
    _loadFastDurations();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!mounted) return;
    _timer = Timer.periodic(Duration(seconds: 1), _updateElapsedTime);
    setState(() {
      _timerRunning = true;
    });
  }

  void _stopTimer() {
    setState(() {
      _timer.cancel();
      _timerRunning = false;
    });
  }

  void _updateElapsedTime(Timer timer) {
    if (_lastMealTime != null && _timerRunning) {
      setState(() {
        _elapsedTime = DateTime.now().difference(_lastMealTime!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String message = _calculateMessage(_elapsedTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Humble'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.favorite),
          onPressed: _showDonateDialog,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.lightbulb),
            onPressed: widget.toggleDarkMode,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (_lastMealTime == null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _lastMealTime = DateTime.now();
                    _startTimer();
                    _saveLastMealTime();
                  });
                },
                child: Text('Start fasting now'),
              ),
            SizedBox(height: 10),
            if (_lastMealTime == null)
              ElevatedButton(
                onPressed: () => _selectLastMealTime(context),
                child: Text('Pick the date and time for your last meal'),
              ),
            SizedBox(height: 20),
            _lastMealTime != null
                ? Column(
                    children: [
                      Text(
                        'Time since your last meal:',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${formatDuration(_elapsedTime)}',
                        style:
                            TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Container(),
            SizedBox(height: 20),
            _fastDurations.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Last fast durations:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: List.generate(
                          _fastDurations.length > 3 ? 3 : _fastDurations.length,
                          (index) => Center(
                            child: Text(
                              '${formatDuration(_fastDurations[index])}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      if (_fastDurations.length > 3)
                        TextButton(
                          onPressed: _showAllDurations,
                          child: Text("Show more..."),
                        ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
      bottomNavigationBar: _lastMealTime != null
          ? Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 35.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _saveLastMealTime();
                    _fastDurations.insert(0, _elapsedTime);
                    _saveFastDurations();
                    _lastMealTime = null;
                    _elapsedTime = Duration(seconds: 0);
                    _stopTimer();
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("End fasting"),
              ),
            )
          : null,
    );
  }

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

  Future<void> _selectLastMealTime(BuildContext context) async {
    if (!mounted) return;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _lastMealTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (selectedDateTime.isAfter(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Please select a date and time before the current time."),
            ),
          );
        } else {
          setState(() {
            _lastMealTime = selectedDateTime;
            _saveLastMealTime();
            _startTimer();
          });
        }
      }
    }
  }

  void _saveLastMealTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_lastMealTime != null) {
      await prefs.setInt('lastMealTime', _lastMealTime!.millisecondsSinceEpoch);
    } else {
      await prefs.remove('lastMealTime');
    }
  }

  void _loadLastMealTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedTime = prefs.getInt('lastMealTime');
    if (storedTime != null) {
      setState(() {
        _lastMealTime = DateTime.fromMillisecondsSinceEpoch(storedTime);
        _startTimer();
      });
    }
  }

  void _loadFastDurations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedDurations = prefs.getStringList('fastDurations');
    if (storedDurations != null) {
      setState(() {
        _fastDurations = storedDurations
            .map((duration) => Duration(seconds: int.parse(duration)))
            .toList();
      });
    }
  }

  void _saveFastDurations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> durationStrings =
        _fastDurations.map((duration) => duration.inSeconds.toString()).toList();
    await prefs.setStringList('fastDurations', durationStrings);
  }

  void _showAllDurations() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'All Fast Durations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ..._fastDurations.map(
                (duration) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    formatDuration(duration),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _calculateMessage(Duration elapsedTime) {
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

  void _showDonateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Donate')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Row(children: [Expanded(child: Text('Lightning:'))]),
              Row(
                children: [
                  Expanded(child: Text('untreu@walletofsatoshi.com')),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: 'untreu@walletofsatoshi.com'))
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied.')),
                        );
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(children: [Expanded(child: Text("On-chain:"))]),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: SelectableText(
                          'bc1qr2zfelma4vmsnwhyn88yctfxjtmu2d0xs55eh3')),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: 'bc1qr2zfelma4vmsnwhyn88yctfxjtmu2d0xs55eh3'))
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied.')),
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Center(child: Text('Close')),
            ),
          ],
        );
      },
    );
  }
}

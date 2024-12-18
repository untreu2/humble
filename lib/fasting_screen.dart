import 'dart:async';
import 'package:flutter/material.dart';

import 'format_utils.dart';
import 'message_utils.dart';
import 'donate_dialog.dart';
import 'storage_service.dart';

class FastingScreen extends StatefulWidget {
  final VoidCallback toggleDarkMode;

  const FastingScreen({Key? key, required this.toggleDarkMode}) : super(key: key);

  @override
  _FastingScreenState createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen> {
  DateTime? _lastMealTime;
  late Timer _timer;
  Duration _elapsedTime = const Duration(seconds: 0);
  bool _timerRunning = false;
  List<Duration> _fastDurations = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateElapsedTime);
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
    _timer = Timer.periodic(const Duration(seconds: 1), _updateElapsedTime);
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
    String message = calculateMessage(_elapsedTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Humble'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: _showDonateDialog,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: widget.toggleDarkMode,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_lastMealTime == null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _lastMealTime = DateTime.now();
                    _startTimer();
                    saveLastMealTime(_lastMealTime);
                  });
                },
                child: const Text('Start fasting now'),
              ),
            const SizedBox(height: 10),
            if (_lastMealTime == null)
              ElevatedButton(
                onPressed: () => _selectLastMealTime(context),
                child: const Text('Pick the date and time for your last meal'),
              ),
            const SizedBox(height: 20),
            _lastMealTime != null
                ? Column(
                    children: [
                      const Text(
                        'Time since your last meal:',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatDuration(_elapsedTime),
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Container(),
            const SizedBox(height: 20),
            _fastDurations.isNotEmpty
                ? _buildLastDurationsList()
                : Container(),
          ],
        ),
      ),
      bottomNavigationBar: _lastMealTime != null
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 35.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    saveLastMealTime(null);
                    _fastDurations.insert(0, _elapsedTime);
                    saveFastDurations(_fastDurations);
                    _lastMealTime = null;
                    _elapsedTime = const Duration(seconds: 0);
                    _stopTimer();
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("End fasting"),
              ),
            )
          : null,
    );
  }

  Widget _buildLastDurationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Last fast durations:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Column(
          children: List.generate(
            _fastDurations.length > 3 ? 3 : _fastDurations.length,
            (index) => Center(
              child: Text(
                formatDuration(_fastDurations[index]),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        if (_fastDurations.length > 3)
          TextButton(
            onPressed: _showAllDurations,
            child: const Text("Show more..."),
          ),
      ],
    );
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
            const SnackBar(
              content: Text("Please select a date and time before the current time."),
            ),
          );
        } else {
          setState(() {
            _lastMealTime = selectedDateTime;
            saveLastMealTime(_lastMealTime);
            _startTimer();
          });
        }
      }
    }
  }

  void _loadLastMealTime() async {
    final time = await loadLastMealTime();
    if (time != null) {
      setState(() {
        _lastMealTime = time;
        _startTimer();
      });
    }
  }

  void _loadFastDurations() async {
    final durations = await loadFastDurations();
    setState(() {
      _fastDurations = durations;
    });
  }

  void _showAllDurations() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'All Fast Durations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._fastDurations.map(
                (duration) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    formatDuration(duration),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDonateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DonateDialog();
      },
    );
  }
}

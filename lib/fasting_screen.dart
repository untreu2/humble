import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'format_utils.dart';
import 'message_utils.dart';
import 'donate_dialog.dart';
import 'storage_service.dart';
import 'all_durations_page.dart';
import 'quotes.dart';

class FastingScreen extends StatefulWidget {
  final VoidCallback toggleDarkMode;

  const FastingScreen({Key? key, required this.toggleDarkMode}) : super(key: key);

  @override
  _FastingScreenState createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen> with TickerProviderStateMixin {
  DateTime? _lastMealTime;
  Timer? _timer;
  Duration _elapsedTime = const Duration(seconds: 0);
  Duration? _selectedFastingGoal;
  bool _timerRunning = false;
  List<Duration> _fastDurations = [];
  final List<int> _fastingOptions = [8, 16, 24, 48, 72];

  Quote? _randomQuote;

  late AnimationController _quoteController;
  late Animation<double> _quoteAnimation;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _quoteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _quoteAnimation = CurvedAnimation(
      parent: _quoteController,
      curve: Curves.easeIn,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _loadData();
    _selectRandomQuote();
  }

  Future<void> _loadData() async {
    await _loadLastMealTime();
    await _loadFastDurations();
    await _loadSelectedFastingGoal();

    if (_lastMealTime != null && _selectedFastingGoal != null) {
      _startTimer();
    }
  }

  void _selectRandomQuote() {
    if (fastingQuotes.isNotEmpty) {
      final random = Random();
      setState(() {
        _randomQuote = fastingQuotes[random.nextInt(fastingQuotes.length)];
      });
      _quoteController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _quoteController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateElapsedTime);
    setState(() {
      _timerRunning = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _timerRunning = false;
    });
  }

  void _updateElapsedTime(Timer timer) {
    if (_lastMealTime != null && _timerRunning && _selectedFastingGoal != null) {
      setState(() {
        _elapsedTime = DateTime.now().difference(_lastMealTime!);
        _progressController.forward(from: 0.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Duration remainingTime = _calculateRemainingTime();
    bool fastingCompleted = remainingTime <= Duration.zero && _selectedFastingGoal != null;
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
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllDurationsPage(durations: _fastDurations),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: widget.toggleDarkMode,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _quoteAnimation,
              child: Container(
                height: 150,
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: _randomQuote != null
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '"${_randomQuote!.text}"',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              '- ${_randomQuote!.author}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: _lastMealTime == null
                    ? _buildFastingOptions()
                    : _buildFastingContent(fastingCompleted, message),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _lastMealTime != null
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 35.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    saveLastMealTime(null);
                    saveSelectedFastingGoal(null);
                    _fastDurations.insert(0, _elapsedTime);
                    saveFastDurations(_fastDurations);
                    _lastMealTime = null;
                    _elapsedTime = const Duration(seconds: 0);
                    _selectedFastingGoal = null;
                    _stopTimer();
                    _selectRandomQuote();
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("End Fasting"),
              ),
            )
          : null,
    );
  }

  Widget _buildFastingButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 40),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildFastingOptions() {
    return Padding(
      key: const ValueKey('fastingOptions'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._fastingOptions.map((hours) {
            return ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                CurvedAnimation(
                  parent: _progressController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: _buildFastingButton('$hours-hour fast', () {
                setState(() {
                  _selectedFastingGoal = Duration(hours: hours);
                  _lastMealTime = DateTime.now();
                  saveLastMealTime(_lastMealTime);
                  saveSelectedFastingGoal(_selectedFastingGoal);
                  _startTimer();
                  _selectRandomQuote();
                });
              }),
            );
          }).toList(),
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.05).animate(
              CurvedAnimation(
                parent: _progressController,
                curve: Curves.easeInOut,
              ),
            ),
            child: _buildFastingButton('Custom', _showCustomFastingDialog),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomFastingDialog() async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom Fasting Duration'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter fasting duration in hours',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final input = controller.text;
                if (input.isNotEmpty) {
                  final hours = int.tryParse(input);
                  if (hours != null && hours > 0) {
                    setState(() {
                      _selectedFastingGoal = Duration(hours: hours);
                      _lastMealTime = DateTime.now();
                      saveLastMealTime(_lastMealTime);
                      saveSelectedFastingGoal(_selectedFastingGoal);
                      _startTimer();
                      _selectRandomQuote();
                    });
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFastingContent(bool fastingCompleted, String message) {
    Duration remainingTime = _calculateRemainingTime();
    String remainingTimeStr = formatDuration(
      remainingTime > Duration.zero ? remainingTime : Duration.zero,
    );

    double progressValue = 0.0;
    if (_selectedFastingGoal != null && _selectedFastingGoal!.inSeconds > 0) {
      final elapsedSeconds = _elapsedTime.inSeconds;
      final goalSeconds = _selectedFastingGoal!.inSeconds;
      progressValue = (elapsedSeconds / goalSeconds).clamp(0.0, 1.0);
    }

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = isDarkMode ? Colors.white : Colors.black;
    Color progressColor = Colors.red;

    return Column(
      key: const ValueKey('fastingContent'),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Text(
            remainingTimeStr,
            key: ValueKey<String>(remainingTimeStr),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        FadeTransition(
          opacity: _quoteAnimation,
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 16.0,
                  backgroundColor: backgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (fastingCompleted)
          FadeTransition(
            opacity: _quoteAnimation,
            child: const Text(
              'Fasting Completed!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Duration _calculateRemainingTime() {
    if (_lastMealTime == null || _selectedFastingGoal == null) {
      return Duration.zero;
    }
    Duration passed = DateTime.now().difference(_lastMealTime!);
    return _selectedFastingGoal! - passed;
  }

  Future<void> _loadLastMealTime() async {
    final time = await loadLastMealTime();
    if (time != null) {
      setState(() {
        _lastMealTime = time;
      });
    }
  }

  Future<void> _loadSelectedFastingGoal() async {
    final goal = await loadSelectedFastingGoal();
    if (goal != null) {
      setState(() {
        _selectedFastingGoal = goal;
      });
    }
  }

  Future<void> _loadFastDurations() async {
    final durations = await loadFastDurations();
    setState(() {
      _fastDurations = durations;
    });
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

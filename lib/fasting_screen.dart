import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'format_utils.dart';
import 'message_utils.dart';
import 'donate_dialog.dart';
import 'storage_service.dart';
import 'quotes.dart';

class FastingScreen extends StatefulWidget {
  final VoidCallback toggleDarkMode;

  const FastingScreen({Key? key, required this.toggleDarkMode})
      : super(key: key);

  @override
  _FastingScreenState createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen>
    with TickerProviderStateMixin {
  DateTime? _lastMealTime;
  Timer? _timer;
  Duration _elapsedTime = const Duration(seconds: 0);
  Duration? _selectedFastingGoal;
  bool _timerRunning = false;
  List<Duration> _fastDurations = [];
  final List<int> _fastingOptions = [8, 16, 24, 48, 72];
  int _selectedFastingIndex = 0;
  Quote? _randomQuote;
  late AnimationController _quoteController;
  late Animation<double> _quoteAnimation;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _quoteController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _quoteAnimation = CurvedAnimation(
      parent: _quoteController,
      curve: Curves.easeOut,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
    if (_lastMealTime != null &&
        _timerRunning &&
        _selectedFastingGoal != null) {
      setState(() {
        _elapsedTime = DateTime.now().difference(_lastMealTime!);
        _progressController.forward(from: 0.0);
      });
    }
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

  Future<void> _showCustomFastingDialog() async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            autofocus: true,
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter fasting duration (hours)',
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final hours = int.tryParse(controller.text);
                  if (hours != null && hours > 0) {
                    _selectedFastingGoal = Duration(hours: hours);
                    _lastMealTime = DateTime.now();
                    saveLastMealTime(_lastMealTime);
                    saveSelectedFastingGoal(_selectedFastingGoal);
                    _startTimer();
                    _selectRandomQuote();
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Start'),
              ),
            ),
          ],
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

  Widget _buildFastingOptions() {
    final List<Widget> pickerItems = [
      for (int hours in _fastingOptions)
        Center(
          child: Text(
            '$hours-hour fast',
            style: const TextStyle(fontSize: 22),
          ),
        ),
      const Center(
        child: Text(
          'Custom',
          style: TextStyle(fontSize: 22),
        ),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 150,
          child: CupertinoPicker(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            itemExtent: 40,
            scrollController:
                FixedExtentScrollController(initialItem: _selectedFastingIndex),
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedFastingIndex = index;
              });
            },
            children: pickerItems,
          ),
        ),
      ],
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
    return Column(
      key: const ValueKey('fastingContent'),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 75),
        Text(
          remainingTimeStr,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
            ),
          ),
        ),
        const SizedBox(height: 20),
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

  Widget _buildActionButton() {
    final bool fastingActive = _lastMealTime != null;
    return ElevatedButton(
      onPressed: () {
        if (!fastingActive) {
          if (_selectedFastingIndex < _fastingOptions.length) {
            setState(() {
              int hours = _fastingOptions[_selectedFastingIndex];
              _selectedFastingGoal = Duration(hours: hours);
              _lastMealTime = DateTime.now();
              saveLastMealTime(_lastMealTime);
              saveSelectedFastingGoal(_selectedFastingGoal);
              _startTimer();
              _selectRandomQuote();
            });
          } else {
            _showCustomFastingDialog();
          }
        } else {
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
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(fastingActive ? 'End fasting' : 'Start fasting'),
    );
  }

  @override
  Widget build(BuildContext context) {
    Duration remainingTime = _calculateRemainingTime();
    bool fastingCompleted =
        remainingTime <= Duration.zero && _selectedFastingGoal != null;
    String message = calculateMessage(_elapsedTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Humble',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
                child: _randomQuote != null
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                        ),
                      )
                    : Container(),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.0)
                          .animate(animation),
                      child: child,
                    ),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 45.0),
        child: _buildActionButton(),
      ),
    );
  }
}

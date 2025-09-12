import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'message_utils.dart';
import 'donate_dialog.dart';
import 'storage_service.dart';
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
    if (_lastMealTime != null && _timerRunning && _selectedFastingGoal != null) {
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
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Enter fasting duration (hours)',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final hours = int.tryParse(controller.text);
                      if (hours != null && hours >= 1 && hours <= 1000) {
                        _selectedFastingGoal = Duration(hours: hours);
                        _lastMealTime = DateTime.now();
                        saveLastMealTime(_lastMealTime);
                        saveSelectedFastingGoal(_selectedFastingGoal);
                        _startTimer();
                        _selectRandomQuote();
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          errorMessage = 'Please enter a valid number between 1 and 1000.';
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Start fasting'),
                  ),
                ),
              ],
            );
          },
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
            scrollController: FixedExtentScrollController(initialItem: _selectedFastingIndex),
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

  Widget _buildProgressBar(double progressValue) {
    const double barWidth = 300.0;
    final theme = Theme.of(context);
    final goalHours = _selectedFastingGoal?.inHours ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: barWidth,
          height: 12,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.dividerColor,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: barWidth * progressValue,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.7),
                      theme.colorScheme.primary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${goalHours}h',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDisplay(Duration duration) {
    final theme = Theme.of(context);
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);

    final baseStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    );

    String pluralize(int value, String unit) {
      return '$value $unit${value == 1 ? '' : 's'}';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          pluralize(hours, 'hour'),
          style: baseStyle.copyWith(fontSize: 60),
        ),
        const SizedBox(height: 8),
        Text(
          pluralize(minutes, 'minute'),
          style: baseStyle.copyWith(fontSize: 32),
        ),
      ],
    );
  }

  Widget _buildFastingContent(bool fastingCompleted, String message) {
    Duration remainingTime = _calculateRemainingTime();
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
        _buildTimeDisplay(remainingTime > Duration.zero ? remainingTime : Duration.zero),
        const SizedBox(height: 20),
        _buildProgressBar(progressValue),
        const SizedBox(height: 20),
        Shimmer.fromColors(
          period: const Duration(seconds: 2),
          baseColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          highlightColor: Theme.of(context).colorScheme.onSurface,
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
          borderRadius: BorderRadius.circular(16),
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
    bool fastingCompleted = remainingTime <= Duration.zero && _selectedFastingGoal != null;
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
                      scale: Tween<double>(begin: 1.0, end: 1.0).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _lastMealTime == null ? _buildFastingOptions() : _buildFastingContent(fastingCompleted, message),
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

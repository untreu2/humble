import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wave.dart';
import 'random_wave_colors.dart';
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

  List<Color> _waveColors = [];

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
    _waveColors = RandomWaveColors.getRandomColors();
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
    if (time != null && mounted) {
      setState(() {
        _lastMealTime = time;
      });
    }
  }

  Future<void> _loadSelectedFastingGoal() async {
    final goal = await loadSelectedFastingGoal();
    if (goal != null && mounted) {
      setState(() {
        _selectedFastingGoal = goal;
      });
    }
  }

  Future<void> _loadFastDurations() async {
    final durations = await loadFastDurations();
    if (mounted) {
      setState(() {
        _fastDurations = durations;
      });
    }
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
                        setState(() {
                          _selectedFastingGoal = Duration(hours: hours);
                          _lastMealTime = DateTime.now();
                        });
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

  Widget _buildWaves() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: CustomWaveWidget(
        size: Size(MediaQuery.of(context).size.width, 280),
        amplitude: 45,
        frequency: 0.6,
        waveLayers: [
          WaveLayer(
            duration: 15000,
            heightFactor: 0.8,
            color: _waveColors.isNotEmpty ? _waveColors[0].withOpacity(0.3) : Colors.blue.withOpacity(0.3),
            waveShape: WaveShapeType.sine,
          ),
          WaveLayer(
            duration: 20000,
            heightFactor: 0.6,
            color: _waveColors.length > 1 ? _waveColors[1].withOpacity(0.4) : Colors.green.withOpacity(0.4),
            waveShape: WaveShapeType.cosine,
          ),
          WaveLayer(
            duration: 18000,
            heightFactor: 0.5,
            color: _waveColors.length > 2 ? _waveColors[2].withOpacity(0.35) : Colors.red.withOpacity(0.35),
            waveShape: WaveShapeType.gerstner,
            steepness: 0.3,
          ),
        ],
      ),
    );
  }

  Widget _buildFastingOptions() {
    final PageController pageController = PageController(initialPage: _selectedFastingIndex);

    return SizedBox(
      height: 280,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  onPageChanged: (int index) {
                    setState(() {
                      _selectedFastingIndex = index;
                    });
                  },
                  itemCount: _fastingOptions.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _fastingOptions.length) {
                      return _buildFastingOptionCard(_fastingOptions[index]);
                    } else {
                      return _buildCustomOptionCard();
                    }
                  },
                ),
                if (_selectedFastingIndex < _fastingOptions.length)
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedFastingIndex < _fastingOptions.length) {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _fastingOptions.length + 1,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: _selectedFastingIndex == index ? 12.0 : 8.0,
                height: _selectedFastingIndex == index ? 12.0 : 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedFastingIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastingOptionCard(int hours) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$hours',
            style: TextStyle(
              fontSize: 192,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'h',
            style: TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomOptionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Custom',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(Duration duration) {
    final theme = Theme.of(context);
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$hours',
          style: TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            height: 0.9,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'h',
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            height: 0.9,
          ),
        ),
        const SizedBox(width: 20),
        Text(
          '$minutes',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 0.9,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'm',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 0.9,
          ),
        ),
      ],
    );
  }

  Widget _buildFastingContent(bool fastingCompleted, String message) {
    Duration remainingTime = _calculateRemainingTime();
    return Column(
      key: const ValueKey('fastingContent'),
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _buildTimeDisplay(remainingTime > Duration.zero ? remainingTime : Duration.zero),
        const SizedBox(height: 50),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
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
              ),
            ),
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
            });
            saveLastMealTime(_lastMealTime);
            saveSelectedFastingGoal(_selectedFastingGoal);
            _startTimer();
            _selectRandomQuote();
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
          });
          _stopTimer();
          _selectRandomQuote();
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 100),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        textStyle: const TextStyle(
          fontSize: 20,
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
    bool fastingActive = _lastMealTime != null;

    return Scaffold(
      body: Stack(
        children: [
          if (fastingActive) _buildWaves(),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Humble',
                        style: GoogleFonts.baskervville(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showDonateDialog,
                            child: Icon(
                              Icons.favorite,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: widget.toggleDarkMode,
                            child: Icon(
                              Icons.lightbulb,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _quoteAnimation,
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: _randomQuote != null
                          ? SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '"${_randomQuote!.text}"',
                                      style: GoogleFonts.baskervville(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    const SizedBox(height: 16.0),
                                    Text(
                                      '- ${_randomQuote!.author}',
                                      style: GoogleFonts.baskervville(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                Positioned(
                  top: 280,
                  left: 0,
                  right: 0,
                  bottom: 160,
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
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: _buildActionButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

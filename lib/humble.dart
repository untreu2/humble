import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fasting_screen.dart';
import 'theme.dart';

class Humble extends StatefulWidget {
  const Humble({Key? key}) : super(key: key);

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
      theme: _isDarkMode ? buildDarkTheme() : buildLightTheme(),
      home: FastingScreen(toggleDarkMode: _toggleDarkMode),
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

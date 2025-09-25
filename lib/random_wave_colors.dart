import 'dart:math';
import 'package:flutter/material.dart';

class RandomWaveColors {
  static final Random _random = Random();

  static final List<Color> _pastelColors = [
    const Color(0xFFFFB3BA),
    const Color(0xFFFFCCCB),
    const Color(0xFFFFDAE1),
    const Color(0xFFFFB7C5),
    const Color(0xFFFFC0CB),
    const Color(0xFFBAFFC9),
    const Color(0xFFD4FFDB),
    const Color(0xFFC8FFD4),
    const Color(0xFFB5F2C4),
    const Color(0xFFADEBC0),
    const Color(0xFFBAE1FF),
    const Color(0xFFB3D9FF),
    const Color(0xFFCCE7FF),
    const Color(0xFFD1ECFF),
    const Color(0xFFB8E6FF),
    const Color(0xFFE4C2FF),
    const Color(0xFFDDB3FF),
    const Color(0xFFF0D7FF),
    const Color(0xFFE6CCFF),
    const Color(0xFFD9B3FF),
    const Color(0xFFFFFFB3),
    const Color(0xFFFFF8DC),
    const Color(0xFFFFFFCC),
    const Color(0xFFFFF4B3),
    const Color(0xFFFFEFB7),
    const Color(0xFFFFD4B3),
    const Color(0xFFFFCCB3),
    const Color(0xFFFFE0B3),
    const Color(0xFFFFDDBF),
    const Color(0xFFFFD7B3),
    const Color(0xFFFFB3B3),
    const Color(0xFFFFCCCC),
    const Color(0xFFFFD4D4),
    const Color(0xFFFFBFBF),
    const Color(0xFFFFDADA),
    const Color(0xFFB3FFFF),
    const Color(0xFFC7FFFF),
    const Color(0xFFD4FFFF),
    const Color(0xFFBFFFFF),
    const Color(0xFFE0FFFF),
    const Color(0xFFE8E8E8),
    const Color(0xFFF0F0F0),
    const Color(0xFFE0E0E0),
    const Color(0xFFECECEC),
    const Color(0xFFDCDCDC),
    const Color(0xFFE6D3B7),
    const Color(0xFFE5CDB6),
    const Color(0xFFEDD5B7),
    const Color(0xFFE8D2B3),
    const Color(0xFFEAD4B8),
    const Color(0xFFF8BBD0),
    const Color(0xFFE1BEE7),
    const Color(0xFFC5E1A5),
    const Color(0xFFFFAB91),
    const Color(0xFFBCAAA4),
  ];

  static List<Color> getRandomColors() {
    List<Color> colors = [];
    List<int> usedIndices = [];

    while (colors.length < 3) {
      int index = _random.nextInt(_pastelColors.length);
      if (!usedIndices.contains(index)) {
        colors.add(_pastelColors[index]);
        usedIndices.add(index);
      }
    }

    return colors;
  }

  static Color getRandomColor() {
    return _pastelColors[_random.nextInt(_pastelColors.length)];
  }

  static List<Color> getAllColors() {
    return List.from(_pastelColors);
  }
}

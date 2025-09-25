import 'dart:math';
import 'package:flutter/material.dart';

class CustomWaveWidget extends StatefulWidget {
  final Size size;
  final double amplitude;
  final double frequency;
  final List<WaveLayer> waveLayers;

  const CustomWaveWidget({
    Key? key,
    required this.size,
    this.amplitude = 20.0,
    this.frequency = 1.0,
    required this.waveLayers,
  }) : super(key: key);

  @override
  _CustomWaveWidgetState createState() => _CustomWaveWidgetState();
}

class _CustomWaveWidgetState extends State<CustomWaveWidget> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];

    for (int i = 0; i < widget.waveLayers.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: widget.waveLayers[i].duration),
        vsync: this,
      );
      final animation = Tween<double>(
        begin: 0.0,
        end: 2 * pi,
      ).animate(controller);

      _controllers.add(controller);
      _animations.add(animation);

      controller.repeat();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: AnimatedBuilder(
        animation: Listenable.merge(_animations),
        builder: (context, child) {
          return CustomPaint(
            painter: WavePainter(
              amplitude: widget.amplitude,
              frequency: widget.frequency,
              waveLayers: widget.waveLayers,
              phases: _animations.map((anim) => anim.value).toList(),
            ),
            size: widget.size,
          );
        },
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double amplitude;
  final double frequency;
  final List<WaveLayer> waveLayers;
  final List<double> phases;

  WavePainter({
    required this.amplitude,
    required this.frequency,
    required this.waveLayers,
    required this.phases,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < waveLayers.length; i++) {
      final layer = waveLayers[i];
      final phase = phases[i];

      final paint = Paint()
        ..color = layer.color
        ..style = PaintingStyle.fill;

      final path = Path();
      final waveHeight = amplitude * layer.heightFactor;
      final baseHeight = size.height * (1.0 - layer.heightFactor);

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 2) {
        final normalizedX = x / size.width;
        double y;

        switch (layer.waveShape) {
          case WaveShapeType.sine:
            y = baseHeight + waveHeight * sin(frequency * normalizedX * 2 * pi + phase);
            break;
          case WaveShapeType.cosine:
            y = baseHeight + waveHeight * cos(frequency * normalizedX * 2 * pi + phase);
            break;
          case WaveShapeType.gerstner:
            final steepness = layer.steepness ?? 0.3;
            y = baseHeight +
                waveHeight *
                    sin(frequency * normalizedX * 2 * pi + phase) *
                    (1 + steepness * cos(frequency * normalizedX * 2 * pi + phase));
            break;
        }

        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class WaveLayer {
  final int duration;
  final double heightFactor;
  final Color color;
  final WaveShapeType waveShape;
  final double? steepness;

  WaveLayer({
    required this.duration,
    required this.heightFactor,
    required this.color,
    this.waveShape = WaveShapeType.sine,
    this.steepness,
  });
}

enum WaveShapeType {
  sine,
  cosine,
  gerstner,
}

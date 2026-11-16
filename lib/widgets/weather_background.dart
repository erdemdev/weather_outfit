import 'dart:math';
import 'package:flutter/material.dart';

class _Particle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;
  double drift;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    this.drift = 0,
  });
}

class WeatherBackground extends StatefulWidget {
  final String condition;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.condition,
    required this.child,
  });

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _initParticles();
  }

  @override
  void didUpdateWidget(WeatherBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.condition != widget.condition) {
      _initParticles();
    }
  }

  void _initParticles() {
    _particles.clear();
    final count = _getParticleCount();
    for (int i = 0; i < count; i++) {
      _particles.add(_createParticle(randomY: true));
    }
  }

  int _getParticleCount() {
    switch (widget.condition) {
      case 'rain':
      case 'drizzle':
        return 80;
      case 'snow':
        return 50;
      case 'thunderstorm':
        return 100;
      case 'clear':
        return 20;
      default:
        return 15;
    }
  }

  _Particle _createParticle({bool randomY = false}) {
    switch (widget.condition) {
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return _Particle(
          x: _random.nextDouble(),
          y: randomY ? _random.nextDouble() : -0.05,
          speed: 0.003 + _random.nextDouble() * 0.005,
          size: widget.condition == 'drizzle'
              ? 1.0 + _random.nextDouble()
              : 1.5 + _random.nextDouble() * 1.5,
          opacity: 0.3 + _random.nextDouble() * 0.4,
          drift: (_random.nextDouble() - 0.5) * 0.001,
        );
      case 'snow':
        return _Particle(
          x: _random.nextDouble(),
          y: randomY ? _random.nextDouble() : -0.05,
          speed: 0.0005 + _random.nextDouble() * 0.002,
          size: 2.0 + _random.nextDouble() * 4,
          opacity: 0.4 + _random.nextDouble() * 0.5,
          drift: (_random.nextDouble() - 0.5) * 0.002,
        );
      case 'clear':
        return _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.0002 + _random.nextDouble() * 0.0005,
          size: 1.5 + _random.nextDouble() * 2.5,
          opacity: 0.15 + _random.nextDouble() * 0.25,
          drift: (_random.nextDouble() - 0.5) * 0.0005,
        );
      default:
        return _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.0001 + _random.nextDouble() * 0.0003,
          size: 2.0 + _random.nextDouble() * 3,
          opacity: 0.1 + _random.nextDouble() * 0.2,
          drift: 0.0003 + _random.nextDouble() * 0.0005,
        );
    }
  }

  void _updateParticles() {
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      p.y += p.speed;
      p.x += p.drift;
      if (p.y > 1.05 || p.x < -0.05 || p.x > 1.05) {
        _particles[i] = _createParticle();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                _updateParticles();
                return CustomPaint(
                  painter: _WeatherPainter(
                    particles: _particles,
                    condition: widget.condition,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _WeatherPainter extends CustomPainter {
  final List<_Particle> particles;
  final String condition;

  _WeatherPainter({required this.particles, required this.condition});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = _getColor().withOpacity(p.opacity);
      final x = p.x * size.width;
      final y = p.y * size.height;

      switch (condition) {
        case 'rain':
        case 'drizzle':
        case 'thunderstorm':
          paint.strokeWidth = p.size * 0.5;
          paint.strokeCap = StrokeCap.round;
          canvas.drawLine(
            Offset(x, y),
            Offset(x + p.drift * size.width * 10, y + p.size * 8),
            paint,
          );
          break;
        case 'snow':
          canvas.drawCircle(Offset(x, y), p.size, paint);
          break;
        default:
          canvas.drawCircle(Offset(x, y), p.size, paint);
          break;
      }
    }
  }

  Color _getColor() {
    switch (condition) {
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return Colors.lightBlueAccent;
      case 'snow':
        return Colors.white;
      case 'clear':
        return Colors.amber;
      default:
        return Colors.white70;
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherPainter oldDelegate) => true;
}

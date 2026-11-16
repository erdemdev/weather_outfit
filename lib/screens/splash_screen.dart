import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> readyFuture;
  final VoidCallback onComplete;
  const SplashScreen({
    super.key,
    required this.readyFuture,
    required this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _weatherCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _iconCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;

  static const _icons = [
    '👗',
    '☀️',
    '🌧️',
    '❄️',
    '🧥',
    '🌤️',
    '👒',
    '🌈',
    '🧣',
    '☂️',
    '😎',
    '🌡️'
  ];
  int _iconIndex = 0;
  bool _didComplete = false;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _weatherCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _iconCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _iconIndex = (_iconIndex + 1) % _icons.length);
          _iconCtrl.forward(from: 0);
        }
      });

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoCtrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
    );

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _fadeCtrl.forward();
        _iconCtrl.forward();
      }
    });
    _waitForReady();
  }

  Future<void> _waitForReady() async {
    try {
      await Future.wait([
        widget.readyFuture,
        Future.delayed(const Duration(milliseconds: 1600)),
      ]);
    } catch (_) {
      // Hazırlıkta hata olsa bile uygulamaya geçişi engelleme.
    }
    if (!mounted || _didComplete) return;
    _didComplete = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _weatherCtrl.dispose();
    _fadeCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A3A4A), Color(0xFF2C6E8A), Color(0xFF3A8FA8)],
          ),
        ),
        child: Stack(
          children: [
            // Animated weather particles
            AnimatedBuilder(
              animation: _weatherCtrl,
              builder: (context, _) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _WeatherParticlePainter(_weatherCtrl.value),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (context, child) => Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedBuilder(
                        animation: _iconCtrl,
                        builder: (context, _) {
                          final t = _iconCtrl.value;
                          final scale = 1.0 - (0.3 * sin(t * pi));
                          final rotation = (1.0 - t) * 0.3;
                          return Transform.scale(
                            scale: scale,
                            child: Transform.rotate(
                              angle: rotation,
                              child: Center(
                                child: Text(
                                  _icons[_iconIndex],
                                  style: const TextStyle(fontSize: 56),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  FadeTransition(
                    opacity: _textFade,
                    child: Text(
                      AppStrings.get('app_title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _textFade,
                    child: Text(
                      AppStrings.lang == 'en'
                          ? 'Dress smart for any weather'
                          : 'Her havaya uygun giyinin',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  FadeTransition(
                    opacity: _textFade,
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white38,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherParticlePainter extends CustomPainter {
  final double progress;
  _WeatherParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final paint = Paint()..color = Colors.white.withOpacity(0.08);

    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final y = (baseY + progress * size.height * speed) % size.height;
      final r = 2.0 + rng.nextDouble() * 4;
      canvas.drawCircle(
          Offset(x + sin(progress * 2 * pi + i) * 15, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherParticlePainter old) => true;
}

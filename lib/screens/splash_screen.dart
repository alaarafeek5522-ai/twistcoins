import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _scaleCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeCtrl.forward();
      _scaleCtrl.forward();
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating ring
                  AnimatedBuilder(
                    animation: _rotateCtrl,
                    builder: (_, __) => Transform.rotate(
                      angle: _rotateCtrl.value * 2 * pi,
                      child: CustomPaint(
                        size: const Size(260, 260),
                        painter: _RingPainter(
                          color: AppTheme.primary,
                          dashCount: 24,
                          radius: 125,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ),
                  // Inner counter-rotating ring
                  AnimatedBuilder(
                    animation: _rotateCtrl,
                    builder: (_, __) => Transform.rotate(
                      angle: -_rotateCtrl.value * 2 * pi * 0.6,
                      child: CustomPaint(
                        size: const Size(260, 260),
                        painter: _RingPainter(
                          color: AppTheme.secondary,
                          dashCount: 16,
                          radius: 105,
                          strokeWidth: 1.5,
                        ),
                      ),
                    ),
                  ),
                  // Glow circle
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Text content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.secondary],
                        ).createShader(bounds),
                        child: Text(
                          'Team Ali',
                          style: GoogleFonts.orbitron(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Developed by Alaa',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: Colors.white54,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final int dashCount;
  final double radius;
  final double strokeWidth;

  _RingPainter({
    required this.color,
    required this.dashCount,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final angleStep = (2 * pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * angleStep;
      final endAngle = startAngle + angleStep * 0.5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => false;
}

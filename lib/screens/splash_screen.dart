import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الدائرة الدوارة حول النص
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // outer ring spinning
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => Transform.rotate(
                      angle: _ctrl.value * 6.28,
                      child: Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(colors: [
                            AppTheme.primary.withOpacity(0),
                            AppTheme.primary,
                            AppTheme.primaryDark,
                            AppTheme.primary.withOpacity(0),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  // inner ring
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => Transform.rotate(
                      angle: -_ctrl.value * 3.14,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // center content
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.card,
                      border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Team Ali',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(height: 1, width: 80, color: AppTheme.primary.withOpacity(0.4)),
                        const SizedBox(height: 6),
                        Text(
                          'By developer Alaa',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white54,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOut),
            const SizedBox(height: 50),
            Text(
              'Twist Coins',
              style: GoogleFonts.playfairDisplay(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                letterSpacing: 3,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
            const SizedBox(height: 8),
            Text(
              'احصل على مكافآتك بسهولة',
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.white38),
            ).animate().fadeIn(delay: 700.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}

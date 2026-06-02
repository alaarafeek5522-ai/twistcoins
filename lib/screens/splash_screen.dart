import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/security_service.dart';
import '../widgets/app_dialogs.dart';
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
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final config = await SecurityService.fetchConfig();

    if (config != null) {
      final appConfig = AppConfig.fromJson(config);

      // signature check
      final sig = await SecurityService.getSignature();
      if (sig != null && sig.isNotEmpty && sig != appConfig.signature) {
        if (mounted) await AppDialogs.showTampered(context);
        return;
      }

      // stopped check
      if (!appConfig.active) {
        if (mounted) await AppDialogs.showStopped(context, appConfig.stopMessage);
        return;
      }

      // update check
      if (appConfig.updateEnabled) {
        if (mounted) {
          await AppDialogs.showUpdate(
            context,
            version: appConfig.version,
            message: appConfig.message,
            url: appConfig.url,
            force: appConfig.forceUpdate,
          );
          if (appConfig.forceUpdate) return;
        }
      }
    }

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
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
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // outer glow
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.12), blurRadius: 60, spreadRadius: 20)],
                    ),
                  ),
                  // spinning arc 1
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => Transform.rotate(
                      angle: _ctrl.value * 6.28,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(colors: [
                            Colors.transparent,
                            AppTheme.primary.withOpacity(0.8),
                            AppTheme.primaryDark,
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),
                  ),
                  // spinning arc 2 (reverse)
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => Transform.rotate(
                      angle: -_ctrl.value * 4.71,
                      child: Container(
                        width: 195,
                        height: 195,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(colors: [
                            Colors.transparent,
                            AppTheme.primary.withOpacity(0.3),
                            Colors.transparent,
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),
                  ),
                  // dots ring
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => Transform.rotate(
                      angle: _ctrl.value * 3.14,
                      child: SizedBox(
                        width: 175,
                        height: 175,
                        child: CustomPaint(painter: _DotsPainter()),
                      ),
                    ),
                  ),
                  // center card
                  Container(
                    width: 155,
                    height: 155,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.card,
                      border: Border.all(color: AppTheme.primary.withOpacity(0.6), width: 2),
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Team Ali',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 1,
                          width: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.transparent,
                              AppTheme.primary.withOpacity(0.6),
                              Colors.transparent,
                            ]),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'By developer Alaa',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.white38,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 900.ms, curve: Curves.easeOut),
            const SizedBox(height: 44),
            Text(
              'Twist Coins',
              style: GoogleFonts.playfairDisplay(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                letterSpacing: 3,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
            const SizedBox(height: 6),
            Text(
              'احصل على مكافآتك بسهولة',
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.white30, letterSpacing: 1),
            ).animate().fadeIn(delay: 700.ms, duration: 800.ms),
            const SizedBox(height: 50),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: AppTheme.cardBorder,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                borderRadius: BorderRadius.circular(4),
              ),
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.primary.withOpacity(0.5)..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * 3.14159 / 180;
      final x = center.dx + radius * 0.92 * (angle - angle + 1) * (i % 2 == 0 ? 1 : 0.7) * (angle.isNaN ? 0 : (i * 0.5 % 1));
      final dotX = center.dx + radius * 0.92 * _cos(angle);
      final dotY = center.dy + radius * 0.92 * _sin(angle);
      canvas.drawCircle(Offset(dotX, dotY), i % 3 == 0 ? 3 : 2, paint);
    }
  }

  double _cos(double a) => (a - a.truncate() + 1) * 0 + _approxCos(a);
  double _sin(double a) => _approxSin(a);

  double _approxCos(double a) {
    double x = a % (2 * 3.14159);
    return 1 - x * x / 2 + x * x * x * x / 24 - x * x * x * x * x * x / 720;
  }

  double _approxSin(double a) {
    double x = a % (2 * 3.14159);
    return x - x * x * x / 6 + x * x * x * x * x / 120;
  }

  @override
  bool shouldRepaint(_) => true;
}

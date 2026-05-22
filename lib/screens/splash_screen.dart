import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/remote_config_service.dart';
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

    Future.delayed(const Duration(seconds: 3), _checkAndNavigate);
  }

  Future<void> _checkAndNavigate() async {
    final config = await RemoteConfig.fetch();
    final status = config['status'] ?? 'active';
    final message = config['message'] ?? '';
    final version = config['version'] ?? '1.0.0';

    if (!mounted) return;

    if (status == 'paused') {
      _showStatusDialog(
        icon: '⏸️',
        title: 'التطبيق متوقف مؤقتاً',
        message: message.isNotEmpty ? message : 'سيعود قريباً، ترقب!',
        canDismiss: false,
      );
      return;
    }

    if (status == 'update') {
      _showStatusDialog(
        icon: '🚀',
        title: 'تحديث جديد متاح',
        message: message.isNotEmpty ? message : 'يرجى تحديث التطبيق للاستمرار',
        canDismiss: false,
        version: version,
      );
      return;
    }

    await _checkTelegram();
  }

  Future<void> _checkTelegram() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('tg_shown') ?? false;
    if (!shown && mounted) {
      await prefs.setBool('tg_shown', true);
      _showTelegramDialog();
    } else {
      _goLogin();
    }
  }

  void _goLogin() {
    if (!mounted) return;
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

  void _showTelegramDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FancyDialog(
        icon: '📢',
        title: 'انضم لقناتنا',
        message: 'تابع آخر التحديثات والأخبار على قناة التليجرام',
        confirmText: 'انضم الآن',
        cancelText: 'لاحقاً',
        onConfirm: () async {
          Navigator.pop(context);
          await launchUrl(Uri.parse('https://t.me/ahrgq'),
              mode: LaunchMode.externalApplication);
          _goLogin();
        },
        onCancel: () {
          Navigator.pop(context);
          _goLogin();
        },
      ),
    );
  }

  void _showStatusDialog({
    required String icon,
    required String title,
    required String message,
    required bool canDismiss,
    String? version,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FancyDialog(
        icon: icon,
        title: title,
        message: message,
        confirmText: 'حسناً',
        onConfirm: () {},
        canDismiss: false,
      ),
    );
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

class _FancyDialog extends StatelessWidget {
  final String icon;
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool canDismiss;

  const _FancyDialog({
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText,
    this.onCancel,
    this.canDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.2),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
              ).createShader(b),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                fontSize: 15,
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (cancelText != null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        cancelText!,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GradientButton(
                        text: confirmText, onTap: onConfirm),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: _GradientButton(text: confirmText, onTap: onConfirm),
              ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _GradientButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: GoogleFonts.orbitron(
            fontSize: 13,
            fontWeight: FontWeight.bold,
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

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
  String _debugMsg = '';

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
      final sig = await SecurityService.getSignature();

      setState(() => _debugMsg = 'APK: ${sig ?? "NULL"}\nGist: ${appConfig.signature}');

      await Future.delayed(const Duration(seconds: 3));

      if (sig != null && sig.isNotEmpty && sig != appConfig.signature) {
        if (mounted) await AppDialogs.showTampered(context);
        return;
      }

      if (!appConfig.active) {
        if (mounted) await AppDialogs.showStopped(context, appConfig.stopMessage);
        return;
      }

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
                  Container(
                    width: 155,
                    height: 155,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.card,
                      border: Border.all(color: AppTheme.primary.withOpacity(0.6), width: 2),
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 20)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Team Ali', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        const SizedBox(height: 5),
                        Container(height: 1, width: 70, color: AppTheme.primary.withOpacity(0.4)),
                        const SizedBox(height: 5),
                        Text('By developer Alaa', style: GoogleFonts.poppins(fontSize: 9, color: Colors.white38)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 900.ms, curve: Curves.easeOut),
            const SizedBox(height: 44),
            Text('Twist Coins', style: GoogleFonts.playfairDisplay(fontSize: 38, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 3)).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 6),
            Text('احصل على مكافآتك بسهولة', style: GoogleFonts.cairo(fontSize: 13, color: Colors.white30)).animate().fadeIn(delay: 700.ms),
            const SizedBox(height: 20),
            // debug
            if (_debugMsg.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                child: Text(_debugMsg, style: const TextStyle(color: Colors.white54, fontSize: 10), textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }
}

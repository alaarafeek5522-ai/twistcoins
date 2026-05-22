import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _verify() async {
    final otp = _otpCtrl.text.trim();
    if (otp.isEmpty) return;
    setState(() => _loading = true);
    final data = await ApiService.verifyOtp(widget.phone, otp);
    setState(() => _loading = false);
    if (data != null) {
      final token = (data['token'] ?? data['authorization'] ?? '')
          .toString()
          .replaceAll('Bearer ', '');
      final accessToken = data['accessToken']?.toString() ?? '';
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              token: token,
              accessToken: accessToken,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP خاطئ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white54),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
              ).createShader(b),
              child: Text(
                'تأكيد OTP',
                style: GoogleFonts.orbitron(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تم الإرسال لـ ${widget.phone}',
              style: GoogleFonts.rajdhani(
                fontSize: 15,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 50),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.secondary.withOpacity(0.4)),
              ),
              child: TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 26,
                  letterSpacing: 10,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: '• • • • • •',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.secondary),
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.secondary, AppTheme.primary],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondary.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _verify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'تأكيد',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

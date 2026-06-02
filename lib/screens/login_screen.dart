import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _codeSent = false;

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(color: Colors.white24),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        filled: true,
        fillColor: AppTheme.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      );

  Widget _goldBtn(String label, VoidCallback onTap, {bool loading = false}) => GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.primaryDark],
            ),
            boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Center(
            child: loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                : Text(label, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // logo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.card,
                  border: Border.all(color: AppTheme.primary.withOpacity(0.6), width: 2),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 25, spreadRadius: 3)],
                ),
                child: const Icon(Icons.monetization_on_rounded, color: AppTheme.primary, size: 42),
              ),
              const SizedBox(height: 24),
              Text('Twist Coins', style: GoogleFonts.playfairDisplay(fontSize: 30, fontWeight: FontWeight.w800, color: AppTheme.primary)),
              const SizedBox(height: 6),
              Text('تسجيل الدخول', style: GoogleFonts.cairo(fontSize: 14, color: Colors.white38)),
              const SizedBox(height: 48),
              // card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.cairo(color: Colors.white),
                      decoration: _inputDeco('رقم الهاتف (01...)', Icons.phone_android),
                      enabled: !_codeSent,
                    ),
                    if (_codeSent) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _codeCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.cairo(color: Colors.white),
                        decoration: _inputDeco('كود التحقق', Icons.lock_outline),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (!_codeSent)
                      _goldBtn('إرسال الكود', () async {
                        final ok = await auth.sendCode(_phoneCtrl.text.trim());
                        if (ok) setState(() => _codeSent = true);
                        else if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل إرسال الكود')));
                      }, loading: auth.loading)
                    else
                      _goldBtn('تحقق والدخول', () async {
                        final ok = await auth.verify(_phoneCtrl.text.trim(), _codeCtrl.text.trim());
                        if (ok && mounted) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'خطأ')));
                        }
                      }, loading: auth.loading),
                    if (_codeSent) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => setState(() { _codeSent = false; _codeCtrl.clear(); }),
                        child: Text('تغيير الرقم', style: GoogleFonts.cairo(color: AppTheme.primary, fontSize: 13)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text('By developer Alaa', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white24)),
            ],
          ),
        ),
      ),
    );
  }
}

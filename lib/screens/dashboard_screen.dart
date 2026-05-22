import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final String token;
  final String accessToken;
  const DashboardScreen(
      {super.key, required this.token, required this.accessToken});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _balance = 0;
  bool _loadingBalance = true;
  bool _runningTasks = false;
  List<Map<String, dynamic>> _taskLog = [];
  late AnimationController _pulseCtrl;
  late AnimationController _rotateCtrl;

  final _redeemOptions = [
    {'label': '50 U → 100 C', 'id': 'EAND_50_UNITS_ID_9'},
    {'label': '100 U → 200 C', 'id': 'EAND_100_UNITS_ID_10'},
    {'label': '150 U → 300 C', 'id': 'EAND_150_UNITS_ID_11'},
    {'label': '300 U → 600 C', 'id': 'EAND_300_UNITS_ID_12'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadBalance();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    setState(() => _loadingBalance = true);
    final b = await ApiService.getBalance(widget.token, widget.accessToken);
    setState(() {
      _balance = b;
      _loadingBalance = false;
    });
  }

  Future<void> _runTasks() async {
    setState(() {
      _runningTasks = true;
      _taskLog = [];
    });
    final tasks =
        await ApiService.getPendingTasks(widget.token, widget.accessToken);
    if (tasks.isEmpty) {
      setState(() {
        _taskLog = [
          {'id': 'كل المهام منتهية', 'ok': true, 'done': true}
        ];
        _runningTasks = false;
      });
      return;
    }
    for (final t in tasks) {
      final tid = t['id'] as String;
      setState(() => _taskLog.add({'id': tid, 'ok': null, 'done': false}));
      final ok =
          await ApiService.executeTask(tid, widget.token, widget.accessToken);
      setState(() {
        final idx = _taskLog.indexWhere((x) => x['id'] == tid && x['done'] == false);
        if (idx != -1) _taskLog[idx] = {'id': tid, 'ok': ok, 'done': true};
      });
      await Future.delayed(const Duration(milliseconds: 400));
    }
    await _loadBalance();
    setState(() => _runningTasks = false);
  }

  Future<void> _redeem(String redeemId, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(label: label),
    );
    if (confirmed != true) return;
    final ok =
        await ApiService.redeem(redeemId, widget.token, widget.accessToken);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: ok ? Colors.green.shade900 : Colors.red.shade900,
        content: Text(
          ok ? '🎉 تم الاستبدال بنجاح!' : '❌ فشل الاستبدال',
          style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ));
      if (ok) _loadBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildBalanceCard(),
                  const SizedBox(height: 28),
                  _sectionTitle('المهام اليومية', Icons.task_alt),
                  const SizedBox(height: 12),
                  _buildTaskButton(),
                  if (_taskLog.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildTaskLog(),
                  ],
                  const SizedBox(height: 28),
                  _sectionTitle('استبدال الوحدات', Icons.card_giftcard),
                  const SizedBox(height: 12),
                  _buildRedeemGrid(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          if (_runningTasks) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _rotateCtrl,
                    builder: (_, __) => Transform.rotate(
                      angle: _rotateCtrl.value * 2 * pi,
                      child: CustomPaint(
                        size: const Size(120, 120),
                        painter: _ArcPainter(
                          color: AppTheme.primary,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _rotateCtrl,
                    builder: (_, __) => Transform.rotate(
                      angle: -_rotateCtrl.value * 2 * pi,
                      child: CustomPaint(
                        size: const Size(120, 120),
                        painter: _ArcPainter(
                          color: AppTheme.secondary,
                          strokeWidth: 2,
                          radius: 45,
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Opacity(
                      opacity: 0.6 + _pulseCtrl.value * 0.4,
                      child: const Icon(
                        Icons.bolt,
                        color: AppTheme.gold,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
              ).createShader(b),
              child: Text(
                'جاري تنفيذ المهام...',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Text(
                '• ' * ((_pulseCtrl.value * 5).toInt() + 1),
                style: TextStyle(
                  color: AppTheme.secondary.withOpacity(0.8),
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
              ).createShader(b),
              child: Text(
                'Team Ali',
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              'Twist Coins Manager',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: Colors.white38,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: _loadBalance,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.2),
            AppTheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.primary.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'رصيدك الحالي',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: Colors.white54,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          _loadingBalance
              ? const CircularProgressIndicator(color: AppTheme.gold)
              : ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [AppTheme.gold, Color(0xFFFFAA00)],
                  ).createShader(b),
                  child: Text(
                    '$_balance',
                    style: GoogleFonts.orbitron(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
          Text(
            'Coins',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              color: Colors.white38,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _runningTasks
              ? const LinearGradient(
                  colors: [Colors.white12, Colors.white12])
              : const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton.icon(
          onPressed: _runningTasks ? null : _runTasks,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(
            _runningTasks ? 'جاري التنفيذ...' : 'تشغيل المهام',
            style: GoogleFonts.orbitron(
                fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskLog() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _taskLog.map((t) {
          final id = t['id'] as String;
          final ok = t['ok'] as bool?;
          final done = t['done'] as bool;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                !done
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.secondary,
                        ),
                      )
                    : Icon(
                        ok == true ? Icons.check_circle : Icons.cancel,
                        color: ok == true
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        size: 16,
                      ),
                const SizedBox(width: 10),
                Text(
                  id,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: !done
                        ? Colors.white54
                        : ok == true
                            ? Colors.greenAccent
                            : Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRedeemGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: _redeemOptions.length,
      itemBuilder: (_, i) {
        final opt = _redeemOptions[i];
        return GestureDetector(
          onTap: () => _redeem(opt['id']!, opt['label']!),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.secondary.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: AppTheme.gold, size: 28),
                const SizedBox(height: 6),
                Text(
                  opt['label']!,
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  _ArcPainter({
    required this.color,
    required this.strokeWidth,
    this.radius = 55,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => false;
}

class _ConfirmDialog extends StatelessWidget {
  final String label;
  const _ConfirmDialog({required this.label});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppTheme.secondary.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondary.withOpacity(0.15),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💎', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 14),
            Text(
              'تأكيد الاستبدال',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 18,
                color: AppTheme.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('إلغاء',
                        style: GoogleFonts.rajdhani(color: Colors.white54)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.secondary]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('تأكيد',
                          style: GoogleFonts.orbitron(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

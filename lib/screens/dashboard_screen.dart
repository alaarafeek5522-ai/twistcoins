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

class _DashboardScreenState extends State<DashboardScreen> {
  int _balance = 0;
  bool _loadingBalance = true;
  bool _runningTasks = false;
  List<String> _taskLog = [];

  final _redeemOptions = [
    {'label': '50 U → 100 C', 'id': 'EAND_50_UNITS_ID_9'},
    {'label': '100 U → 200 C', 'id': 'EAND_100_UNITS_ID_10'},
    {'label': '150 U → 300 C', 'id': 'EAND_150_UNITS_ID_11'},
    {'label': '300 U → 600 C', 'id': 'EAND_300_UNITS_ID_12'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBalance();
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
      setState(() => _taskLog = ['✅ كل المهام منتهية']);
      setState(() => _runningTasks = false);
      return;
    }
    for (final t in tasks) {
      final tid = t['id'] as String;
      final ok =
          await ApiService.executeTask(tid, widget.token, widget.accessToken);
      setState(() => _taskLog.add(ok ? '✅ $tid' : '❌ $tid'));
      await Future.delayed(const Duration(milliseconds: 400));
    }
    await _loadBalance();
    setState(() => _runningTasks = false);
  }

  Future<void> _redeem(String redeemId) async {
    final ok =
        await ApiService.redeem(redeemId, widget.token, widget.accessToken);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? '🎉 تم الاستبدال بنجاح!' : '❌ فشل الاستبدال'),
    ));
    if (ok) _loadBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
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
                    icon: const Icon(Icons.refresh_rounded,
                        color: Colors.white38),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Balance card
              Container(
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
                        ? const CircularProgressIndicator(
                            color: AppTheme.gold)
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
              ),
              const SizedBox(height: 24),

              // Tasks section
              _sectionTitle('المهام اليومية', Icons.task_alt),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _runningTasks
                        ? LinearGradient(colors: [
                            Colors.white12,
                            Colors.white12
                          ])
                        : const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.secondary],
                          ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _runningTasks ? null : _runTasks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _runningTasks
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      _runningTasks ? 'جاري التنفيذ...' : 'تشغيل المهام',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              if (_taskLog.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _taskLog
                        .map((l) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3),
                              child: Text(
                                l,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 14,
                                  color: l.startsWith('✅')
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Redeem section
              _sectionTitle('استبدال الوحدات', Icons.card_giftcard),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemCount: _redeemOptions.length,
                itemBuilder: (_, i) {
                  final opt = _redeemOptions[i];
                  return GestureDetector(
                    onTap: () => _redeem(opt['id']!),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.secondary.withOpacity(0.3),
                        ),
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
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
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

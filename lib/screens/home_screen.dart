import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _packages = [
    {'label': '50 وحدة', 'sub': '100 نقطة', 'id': 'EAND_50_UNITS_ID_9', 'icon': Icons.bolt},
    {'label': '100 وحدة', 'sub': '200 نقطة', 'id': 'EAND_100_UNITS_ID_10', 'icon': Icons.flash_on},
    {'label': '150 وحدة', 'sub': '300 نقطة', 'id': 'EAND_150_UNITS_ID_11', 'icon': Icons.star},
    {'label': '300 وحدة', 'sub': '600 نقطة', 'id': 'EAND_300_UNITS_ID_12', 'icon': Icons.workspace_premium},
  ];

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(t, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.primary.withOpacity(0.15), AppTheme.bg],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Text('Twist Coins', style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                      const SizedBox(height: 20),
                      // balance card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.4), width: 1.5),
                          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.15), blurRadius: 20)],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.monetization_on_rounded, color: AppTheme.primary, size: 28),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('رصيد النقاط', style: GoogleFonts.cairo(fontSize: 11, color: Colors.white38)),
                                Text('${auth.balance}', style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                              ],
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: auth.refreshBalance,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.refresh_rounded, color: AppTheme.primary, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // tasks
                _sectionTitle('المهام'),
                GestureDetector(
                  onTap: () async {
                    final done = await auth.doTasks();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم إنجاز $done مهمة ✅', style: GoogleFonts.cairo()),
                          backgroundColor: AppTheme.primary.withOpacity(0.9),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppTheme.card, AppTheme.surface]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary.withOpacity(0.15),
                          ),
                          child: auth.loading
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
                                )
                              : const Icon(Icons.play_circle_filled_rounded, color: AppTheme.primary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('تشغيل المهام', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                              Text('اضغط لإنجاز كل المهام المتاحة', style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white24),
                      ],
                    ),
                  ),
                ),

                // redeem
                _sectionTitle('استبدال النقاط'),
                ...List.generate(_packages.length, (i) {
                  final pkg = _packages[i];
                  final req = int.parse(pkg['sub'].toString().replaceAll(RegExp(r'[^0-9]'), ''));
                  final canRedeem = auth.balance >= req;
                  return GestureDetector(
                    onTap: canRedeem ? () async {
                      final ok = await auth.redeem(pkg['id'] as String);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? '✅ تم الاستبدال' : '❌ فشل الاستبدال', style: GoogleFonts.cairo()),
                            backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        );
                      }
                    } : null,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: canRedeem ? AppTheme.card : AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: canRedeem ? AppTheme.primary.withOpacity(0.4) : AppTheme.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (canRedeem ? AppTheme.primary : Colors.white12).withOpacity(0.15),
                            ),
                            child: Icon(pkg['icon'] as IconData, color: canRedeem ? AppTheme.primary : Colors.white24, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pkg['label'] as String, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: canRedeem ? Colors.white : Colors.white38)),
                                Text(pkg['sub'] as String, style: GoogleFonts.cairo(fontSize: 12, color: canRedeem ? AppTheme.primary : Colors.white24)),
                              ],
                            ),
                          ),
                          Icon(canRedeem ? Icons.check_circle_outline : Icons.lock_outline, color: canRedeem ? AppTheme.primary : Colors.white24, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class AppDialogs {
  static Future<void> showStopped(BuildContext context, String msg) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FancyDialog(
        icon: Icons.block_rounded,
        iconColor: Colors.redAccent,
        title: 'تم إيقاف التطبيق',
        message: msg,
        actions: [],
      ),
    );
  }

  static Future<void> showTampered(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FancyDialog(
        icon: Icons.security_rounded,
        iconColor: Colors.redAccent,
        title: 'تحذير أمني',
        message: 'تم اكتشاف تعديل غير مصرح به على التطبيق.\nلحماية بياناتك، تم إيقاف التطبيق.',
        actions: [],
      ),
    );
  }

  static Future<bool> showUpdate(BuildContext context, {
    required String version,
    required String message,
    required String url,
    required bool force,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: !force,
      builder: (_) => _FancyDialog(
        icon: Icons.system_update_rounded,
        iconColor: AppTheme.primary,
        title: 'تحديث متاح v$version',
        message: message,
        actions: [
          if (!force)
            _DialogAction(
              label: 'لاحقاً',
              onTap: () => Navigator.pop(context, false),
              outlined: true,
            ),
          _DialogAction(
            label: 'تحديث الآن',
            onTap: () async {
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              if (context.mounted) Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _FancyDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final List<_DialogAction> actions;

  const _FancyDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: iconColor.withOpacity(0.15), blurRadius: 40, spreadRadius: 5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // icon circle
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.1),
                border: Border.all(color: iconColor.withOpacity(0.4), width: 2),
              ),
              child: Icon(icon, color: iconColor, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.white54, height: 1.6),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: actions
                    .map((a) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: a,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DialogAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  const _DialogAction({required this.label, required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: outlined
              ? null
              : const LinearGradient(colors: [AppTheme.primaryDark, AppTheme.primary]),
          border: outlined ? Border.all(color: AppTheme.cardBorder) : null,
          color: outlined ? AppTheme.card : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: outlined ? Colors.white54 : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

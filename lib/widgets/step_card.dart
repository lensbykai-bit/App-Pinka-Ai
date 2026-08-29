import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StepCard extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final String? fileName;
  final VoidCallback onTap;

  const StepCard({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1B1720) : AppTheme.card,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: selected ? AppTheme.pink : AppTheme.cardBorder, width: selected ? 1.5 : 1),
          boxShadow: selected ? const [BoxShadow(color: Color(0x33FF3E9D), blurRadius: 24)] : const [],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: const Color(0xFF1E2430), borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: selected ? AppTheme.pinkSoft : AppTheme.textSecondary, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(fileName ?? subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: fileName != null ? AppTheme.pinkSoft : AppTheme.textSecondary, fontSize: 14, height: 1.35)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded, color: selected ? AppTheme.pink : AppTheme.textSecondary, size: 29),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/widgets/app_card.dart';
import 'package:unigpa/core/widgets/app_list_tile.dart';

class AppSettingTile extends StatelessWidget {
  const AppSettingTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: EdgeInsets.zero,
      child: AppListTile(
        title: title,
        subtitle: subtitle,
        showDivider: false,
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: colors.textHint)
      ),
    );
  }
}

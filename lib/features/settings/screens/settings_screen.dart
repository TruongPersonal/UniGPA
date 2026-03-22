import 'package:flutter/material.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/widgets/app_card.dart';
import 'package:unigpa/core/widgets/app_list_tile.dart';
import 'semester_management_screen.dart';
import 'grade_config_screen.dart';

class _SettingItem extends StatelessWidget {
  const _SettingItem({
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
        trailing: Icon(Icons.chevron_right_rounded, color: colors.textHint),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          _SettingItem(
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.primary,
            title: 'Học vụ',
            subtitle: 'Quản lý năm học và học kỳ',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SemesterManagementScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: Icons.grade_rounded,
            iconColor: AppColors.accent,
            title: 'Cấu hình',
            subtitle: 'Quản lý điểm 4 và khoảng điểm 10',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GradeConfigScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

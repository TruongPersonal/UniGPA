import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/app_bottom_sheet.dart';
import 'package:unigpa/features/settings/providers/theme_provider.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return AppBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Chọn giao diện', style: AppTextStyles.headingMedium),
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            context,
            mode: ThemeMode.system,
            title: 'Theo hệ thống',
            icon: Icons.settings_brightness_rounded,
            currentMode: themeProvider.themeMode,
          ),
          _buildThemeOption(
            context,
            mode: ThemeMode.light,
            title: 'Giao diện sáng',
            icon: Icons.light_mode_rounded,
            currentMode: themeProvider.themeMode,
          ),
          _buildThemeOption(
            context,
            mode: ThemeMode.dark,
            title: 'Giao diện tối',
            icon: Icons.dark_mode_rounded,
            currentMode: themeProvider.themeMode,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required ThemeMode mode,
    required String title,
    required IconData icon,
    required ThemeMode currentMode,
  }) {
    final isSelected = mode == currentMode;
    final colors = context.colors;

    return ListTile(
      onTap: () {
        context.read<ThemeProvider>().setThemeMode(mode);
        Navigator.pop(context);
      },
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : colors.textSecondary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isSelected ? AppColors.primary : colors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unigpa/core/widgets/app_setting_tile.dart';
import 'package:unigpa/features/grades/providers/grades_provider.dart';
import 'package:unigpa/features/grades/providers/semester_provider.dart';
import 'package:unigpa/features/settings/providers/theme_provider.dart';
import 'package:unigpa/core/utils/csv_service.dart';
import '../widgets/theme_selector.dart';
import '../widgets/guide_bottom_sheet.dart';
import '../widgets/about_bottom_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Cài đặt chung',
              style: AppTextStyles.headingSmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              String themeName = '';
              IconData themeIcon = Icons.settings_brightness_rounded;
              switch (themeProvider.themeMode) {
                case ThemeMode.light:
                  themeName = 'Sáng';
                  themeIcon = Icons.light_mode_rounded;
                  break;
                case ThemeMode.dark:
                  themeName = 'Tối';
                  themeIcon = Icons.dark_mode_rounded;
                  break;
                case ThemeMode.system:
                  themeName = 'Hệ thống';
                  themeIcon = Icons.settings_brightness_rounded;
                  break;
              }

              return AppSettingTile(
                icon: themeIcon,
                iconColor: Colors.purple,
                title: 'Giao diện',
                subtitle: 'Đang chọn: $themeName',
                onTap: () => _showThemeSelector(context),
              );
            },
          ),
          const SizedBox(height: 12),
          AppSettingTile(
            icon: Icons.upload_file_rounded,
            iconColor: Colors.blue,
            title: 'Sao lưu',
            subtitle: 'Xuất toàn bộ môn học ra file CSV',
            onTap: () async {
              await CsvService.exportSubjects(
                context.read<GradesProvider>().subjects,
              );
            },
          ),
          const SizedBox(height: 12),
          AppSettingTile(
            icon: Icons.download_for_offline_rounded,
            iconColor: Colors.green,
            title: 'Khôi phục',
            subtitle: 'Nhập dữ liệu từ file CSV của bạn',
            onTap: () => _handleImportCsv(context),
          ),
          const SizedBox(height: 12),
          AppSettingTile(
            icon: Icons.delete_forever_rounded,
            iconColor: AppColors.error,
            title: 'Xoá hết',
            subtitle: 'Xoá vĩnh viễn mọi học kỳ và môn học',
            onTap: () => _showClearAllConfirm(context),
          ),
          const SizedBox(height: 24),
          Text(
            'Thông tin chung',
            style: AppTextStyles.headingSmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          AppSettingTile(
            icon: Icons.help_outline_rounded,
            iconColor: Colors.teal,
            title: 'Hướng dẫn',
            subtitle: 'Cách sử dụng ứng dụng hiệu quả',
            onTap: () => _showGuideBottomSheet(context),
          ),
          const SizedBox(height: 12),
          AppSettingTile(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.purple,
            title: 'Thông tin',
            subtitle: 'Thông tin phiên bản',
            onTap: () => _showAboutBottomSheet(context),
          ),
          const SizedBox(height: 12),
          AppSettingTile(
            icon: Icons.star_outline_rounded,
            iconColor: Colors.amber,
            title: 'Đánh giá',
            subtitle: 'Ủng hộ ứng dụng của tôi',
            onTap: () => _launchUrl(context, 'https://github.com/truongpersonal/unigpa'),
          ),
          const SizedBox(height: 12),
          AppSettingTile(
            icon: Icons.alternate_email_rounded,
            iconColor: Colors.blue,
            title: 'Liên hệ',
            subtitle: 'Góp ý hoặc báo lỗi trực tiếp',
            onTap: () => _launchUrl(context, 'mailto:ngoquangtruong.isme@gmail.com'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _showClearAllConfirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá tất cả dữ liệu?'),
        content: const Text(
          'Tất cả học kỳ và môn học của bạn sẽ bị xoá vĩnh viễn. Hành động này không thể hoàn tác!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      await context.read<GradesProvider>().clearAllData();
      if (!context.mounted) return;
      await context.read<SemesterProvider>().deleteAllData();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xoá toàn bộ dữ liệu thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemeSelector(),
    );
  }

  Future<void> _handleImportCsv(BuildContext context) async {
    final subjects = await CsvService.importSubjects();
    if (subjects == null) return;

    if (!context.mounted) return;
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy dữ liệu hợp lệ!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final gradesProvider = context.read<GradesProvider>();
    final semesterProvider = context.read<SemesterProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await gradesProvider.importSubjectsFromCsv(subjects);
      if (context.mounted) {
        semesterProvider.reload();
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Đã nhập dữ liệu ${subjects.length} môn học!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi nhập dữ liệu!'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showGuideBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GuideBottomSheet(),
    );
  }

  void _showAboutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AboutBottomSheet(),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở liên kết này.')),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/app_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'semester_management_screen.dart';
import 'grade_config_screen.dart';
import 'package:unigpa/core/widgets/app_setting_tile.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/data/providers/gpa_provider.dart';
import 'package:unigpa/data/providers/semester_provider.dart';



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
              style: AppTextStyles.labelLarge.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          AppSettingTile(
            icon: Icons.calendar_today_rounded,
            iconColor: Colors.blue,
            title: 'Học kỳ',
            subtitle: 'Quản lý danh sách năm học & học kỳ',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SemesterManagementScreen()),
            ),
          ),
          const SizedBox(height: 12),
          AppSettingTile(
            icon: Icons.grade_rounded,
            iconColor: Colors.orange,
            title: 'Thang điểm',
            subtitle: 'Cấu hình hệ điểm chữ và trọng số',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GradeConfigScreen()),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Hỗ trợ & Thông tin',
            style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary),
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
            title: 'Về tôi',
            subtitle: 'Thông tin phiên bản và tác giả',
            onTap: () => _showAboutBottomSheet(context),
          ),
          const SizedBox(height: 12),
          AppSettingTile(
            icon: Icons.star_outline_rounded,
            iconColor: Colors.amber,
            title: 'Đánh giá',
            isTrailing: false,
            subtitle: 'Ủng hộ ứng dụng trên cửa hàng',
            onTap: () => _launchUrl(context, 'https://github.com/truongpersonal/unigpa'),
          ),
          const SizedBox(height: 12),
          AppSettingTile(
            icon: Icons.alternate_email_rounded,
            iconColor: Colors.blue,
            isTrailing: false,
            title: 'Liên hệ',
            subtitle: 'Góp ý hoặc báo lỗi trực tiếp',
            onTap: () => _launchUrl(context, 'mailto:ngoquangtruong.isme@gmail.com'),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Dữ liệu',
              style: AppTextStyles.labelLarge.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          AppSettingTile(
            icon: Icons.delete_forever_rounded,
            iconColor: AppColors.error,
            title: 'Xoá tất cả dữ liệu',
            subtitle: 'Xoá vĩnh viễn mọi học kỳ và môn học',
            onTap: () => _showClearAllConfirm(context),
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
      await context.read<GPAProvider>().clearAllData();
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

  void _showGuideBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Hướng dẫn sử dụng',
                style: AppTextStyles.headingMedium,
              ),
            ),
            const SizedBox(height: 16),
            _buildGuideStep(
              context,
              '1',
              'Thiết lập học vụ',
              'Vào mục "Học vụ" để thêm Năm học và các Học kỳ bạn đang theo học.',
            ),
            _buildGuideStep(
              context,
              '2',
              'Thêm môn học',
              'Ở tab "Bảng điểm", chọn học kỳ và thêm các môn học với số tín chỉ, hệ số quá trình.',
            ),
            _buildGuideStep(
              context,
              '3',
              'Nhập điểm & Theo dõi',
              'Nhập điểm quá trình và điểm thi. App sẽ tự động tính GPA học kỳ và toàn khóa.',
            ),
            _buildGuideStep(
              context,
              '4',
              'Sao lưu dữ liệu',
              'Sử dụng tính năng Xuất/Nhập CSV ở trang chủ để không bao giờ mất dữ liệu.',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep(
    BuildContext context,
    String step,
    String title,
    String desc,
  ) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text('UniGPA', style: AppTextStyles.headingLarge),
            Text(
              'Phiên bản 1.0.0',
              style: AppTextStyles.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Ứng dụng quản lý điểm và tính GPA chuyên nghiệp dành cho sinh viên Việt Nam. Giúp bạn theo dõi lộ trình học tập hiệu quả.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Phát triển bởi ❤️ TruongPersonal',
              style: AppTextStyles.labelMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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

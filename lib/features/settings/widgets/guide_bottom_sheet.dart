import 'package:flutter/material.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/app_bottom_sheet.dart';

class GuideBottomSheet extends StatelessWidget {
  const GuideBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
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
            'Sử dụng tính năng Xuất/Nhập CSV ở mục "Cài đặt" để không bao giờ mất dữ liệu.',
          ),
          const SizedBox(height: 20),
        ],
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
            decoration: const BoxDecoration(
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
}

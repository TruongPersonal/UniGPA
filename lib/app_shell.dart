import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/data/providers/theme_provider.dart';
import 'package:unigpa/data/providers/semester_provider.dart';
import 'package:unigpa/features/grades/screens/add_subject_screen.dart';
import 'package:unigpa/features/grades/screens/grades_screen.dart';
import 'package:unigpa/features/home/screens/home_screen.dart';
import 'package:unigpa/features/settings/screens/settings_screen.dart';
import 'package:unigpa/core/widgets/app_logo_title.dart';
import 'package:unigpa/core/utils/csv_service.dart';
import 'package:unigpa/data/providers/gpa_provider.dart';
import 'package:unigpa/core/widgets/app_bottom_sheet.dart';
import 'package:unigpa/core/widgets/app_list_tile.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';

class _TabItem {
  const _TabItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _tabs = [
    _TabItem(icon: Icons.home_rounded, label: 'Tổng quan'),
    _TabItem(icon: Icons.grid_view_rounded, label: 'Bảng điểm'),
    _TabItem(icon: Icons.settings_rounded, label: 'Cài đặt'),
  ];

  static const List<Widget> _screens = [
    HomeScreen(),
    GradesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeProvider = context.watch<ThemeProvider>();
    final hasSemesters = context.watch<SemesterProvider>().semesters.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, colors, themeProvider),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: IndexedStack(index: _currentIndex, children: _screens),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context, hasSemesters),
      bottomNavigationBar: _buildBottomNavBar(colors),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, bool hasSemesters) {
    if (_currentIndex == 0) {
      return FloatingActionButton(
        onPressed: () => _showCsvBottomSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.import_export_rounded),
      );
    }

    if (_currentIndex == 1 && hasSemesters) {
      return FloatingActionButton(
        onPressed: () => showAddSubjectSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      );
    }

    return null;
  }

  void _showCsvBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = context.colors;
        return AppBottomSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  'Dữ liệu CSV',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppListTile(
                leading: const Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.primary,
                ),
                title: 'Xuất CSV',
                subtitle: 'Lưu toàn bộ dữ liệu môn học ra file CSV',
                onTap: () async {
                  Navigator.pop(context);
                  await CsvService.exportSubjects(
                    context.read<GPAProvider>().subjects,
                  );
                },
              ),
              const SizedBox(height: 8),
              AppListTile(
                leading: const Icon(
                  Icons.download_for_offline_rounded,
                  color: AppColors.primary,
                ),
                title: 'Nhập từ CSV',
                subtitle: 'Khôi phục dữ liệu từ file sao lưu của bạn',
                onTap: () async {
                  final subjects = await CsvService.importSubjects();

                  if (!context.mounted) return;
                  Navigator.pop(context);

                  if (subjects == null) {
                    return;
                  }

                  if (subjects.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Không tìm thấy dữ liệu hợp lệ trong file CSV!',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                    return;
                  }

                  final gpaProvider = context.read<GPAProvider>();
                  final semesterProvider = context.read<SemesterProvider>();

                  await gpaProvider.importSubjects(subjects, semesterProvider);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã nhập dữ liệu ${subjects.length} môn học!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    AppColorsData colors,
    ThemeProvider themeProvider,
  ) {
    return AppBar(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 20,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: colors.divider),
      ),
      title: const AppLogoTitle(),

      actions: [
        IconButton(
          tooltip: themeProvider.themeMode == ThemeMode.system
              ? 'Giao diện hệ thống'
              : themeProvider.themeMode == ThemeMode.light
              ? 'Giao diện sáng'
              : 'Giao diện tối',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                RotationTransition(turns: anim, child: child),
            child: Icon(
              themeProvider.themeMode == ThemeMode.system
                  ? Icons.brightness_6_rounded
                  : themeProvider.themeMode == ThemeMode.light
                  ? Icons.wb_sunny_rounded
                  : Icons.nightlight_round,
              key: ValueKey(themeProvider.themeMode),
              color: colors.textSecondary,
              size: 20,
            ),
          ),
          onPressed: themeProvider.toggleTheme,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBottomNavBar(AppColorsData colors) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.divider, width: 1)),
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.icon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

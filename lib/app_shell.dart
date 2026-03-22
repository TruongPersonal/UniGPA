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
      floatingActionButton: Visibility(
        visible: _currentIndex == 1 && hasSemesters,
        child: FloatingActionButton(
          onPressed: () => showAddSubjectSheet(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(colors),
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

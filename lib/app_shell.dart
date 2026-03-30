import 'package:flutter/material.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/app_drawer.dart';
import 'package:unigpa/core/widgets/app_logo_title.dart';
import 'package:unigpa/core/widgets/theme_toggle_button.dart';
import 'package:unigpa/features/grades/screens/grades_screen.dart';
import 'package:unigpa/features/home/screens/home_screen.dart';
import 'package:unigpa/features/settings/screens/settings_screen.dart';

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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const AppDrawer(),
        backgroundColor: colors.background,
        appBar: _buildAppBar(context, colors),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.translucent,
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(colors),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppColorsData colors) {
    return AppBar(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Mở điều hướng',
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      titleSpacing: 20,
      bottom: _currentIndex == 1
          ? TabBar(
              tabs: const [
                Tab(text: 'Điểm số'),
                Tab(text: 'Học vụ'),
                Tab(text: 'Thang điểm'),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor: colors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTextStyles.labelLarge,
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: colors.divider),
            ),
      title: const AppLogoTitle(),
      actions: const [
        ThemeToggleButton(),
        SizedBox(width: 4),
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

import 'package:flutter/material.dart';
import 'package:unigpa/core/widgets/app_drawer.dart';
import 'package:unigpa/core/widgets/theme_toggle_button.dart';
import 'package:unigpa/core/widgets/user_avatar_action.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Mở điều hướng',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [
          UserAvatarAction(),
          SizedBox(width: 8),
          ThemeToggleButton(),
          SizedBox(width: 4),
        ],
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school_rounded, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 8),
              const Text(
                'UniGPA',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueAccent,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '$greeting 👋',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

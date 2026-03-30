import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/features/settings/providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final mode = themeProvider.themeMode;
        final String tooltip;
        final IconData icon;

        if (mode == ThemeMode.light) {
          tooltip = 'Giao diện sáng';
          icon = Icons.wb_sunny_rounded;
        } else if (mode == ThemeMode.dark) {
          tooltip = 'Giao diện tối';
          icon = Icons.nightlight_round;
        } else {
          tooltip = 'Giao diện hệ thống';
          icon = Icons.brightness_6_rounded;
        }

        return IconButton(
          tooltip: tooltip,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                RotationTransition(turns: anim, child: child),
            child: Icon(icon, key: ValueKey(mode), size: 20),
          ),
          onPressed: themeProvider.toggleTheme,
        );
      },
    );
  }
}

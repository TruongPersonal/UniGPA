import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/data/providers/theme_provider.dart';

class AppLogoTitle extends StatelessWidget {
  const AppLogoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeProvider = context.watch<ThemeProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          themeProvider.isDark
              ? 'assets/logo_transparent_white.png'
              : 'assets/logo_transparent_black.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Uni',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const TextSpan(
                    text: 'GPA',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'by TruongPersonal',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

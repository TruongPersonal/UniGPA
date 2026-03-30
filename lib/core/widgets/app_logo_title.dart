import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/features/settings/providers/theme_provider.dart';

class AppLogoTitle extends StatelessWidget {
  final bool isWhite;
  
  const AppLogoTitle({super.key, this.isWhite = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeProvider = context.watch<ThemeProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          isWhite || themeProvider.isDark
              ? 'assets/images/logo_transparent_white.png'
              : 'assets/images/logo_transparent_black.png',
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
                      color: isWhite ? Colors.white : colors.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  TextSpan(
                    text: 'GPA',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: isWhite ? Colors.white : AppColors.primary,
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
                color: isWhite ? Colors.white70 : colors.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

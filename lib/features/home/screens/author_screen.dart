import 'package:flutter/material.dart';
import 'package:unigpa/core/widgets/app_drawer.dart';
import 'package:unigpa/core/widgets/theme_toggle_button.dart';
import 'package:unigpa/core/widgets/user_avatar_action.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/features/settings/providers/theme_provider.dart';

class AuthorScreen extends StatelessWidget {
  const AuthorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Mở điều hướng',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        elevation: 0,
        actions: const [
          UserAvatarAction(),
          SizedBox(width: 8),
          ThemeToggleButton(),
          SizedBox(width: 4),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 85,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/images/me.png'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            const Text(
              'Ngô Quang Trường',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '23T1020573',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildInfoCard(
                    context,
                    isDark: isDark,
                    icon: Icons.computer_rounded,
                    title: 'Sinh viên',
                    content: 'Chuyên ngành Công nghệ phần mềm',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    isDark: isDark,
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'Đồ án',
                    content: 'Lập trình ứng dụng cho các thiết bị di động',
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialBtn(Icons.facebook_rounded, Colors.blue,
                          'https://facebook.com/truongpersonal'),
                      const SizedBox(width: 24),
                      _buildSocialBtn(
                          Icons.code_rounded,
                          isDark ? Colors.white : Colors.black87,
                          'https://github.com/TruongPersonal'),
                      const SizedBox(width: 24),
                      _buildSocialBtn(Icons.alternate_email_rounded,
                          Colors.redAccent, 'mailto:ngoquangtruong.isme@gmail.com'),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: Colors.blueAccent),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialBtn(IconData icon, Color color, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Could not launch $url');
        }
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 30),
        ),
      ),
    );
  }
}

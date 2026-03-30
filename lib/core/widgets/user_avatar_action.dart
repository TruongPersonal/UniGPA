import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/features/auth/providers/auth_provider.dart';
import 'package:unigpa/features/home/screens/profile_screen.dart';

class UserAvatarAction extends StatelessWidget {
  const UserAvatarAction({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Xin chào,',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                user?.firstName ?? 'Bạn',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blueAccent.withOpacity(0.1),
            backgroundImage: (user?.image.isNotEmpty ?? false)
                ? NetworkImage(user!.image)
                : null,
            child: (user?.image.isNotEmpty ?? false)
                ? null
                : const Icon(Icons.person, size: 20),
          ),
        ],
      ),
    );
  }
}

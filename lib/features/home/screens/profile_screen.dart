import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/widgets/app_logo_title.dart';
import 'package:unigpa/core/widgets/theme_toggle_button.dart';
import 'package:unigpa/features/auth/providers/auth_provider.dart';
import 'package:unigpa/features/settings/providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _imageController;
  late String _selectedGender;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _imageController = TextEditingController(text: user?.image ?? '');

    final gen = user?.gender.toLowerCase() ?? '';
    _selectedGender = gen == 'female' ? 'female' : 'male';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      gender: _selectedGender,
      image: _imageController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _toggleEdit() {
    if (_isEditing) {
      _saveProfile();
    } else {
      setState(() => _isEditing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isDark = context.watch<ThemeProvider>().isDark;
    final isLoading = authProvider.isLoading;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hồ sơ')),
        body: const Center(child: Text('Chưa đăng nhập')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Trở về',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const AppLogoTitle(),
        centerTitle: true,
        elevation: 0,
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : _toggleEdit,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        backgroundImage: _imageController.text.isNotEmpty
                            ? NetworkImage(_imageController.text)
                            : null,
                        child: _imageController.text.isEmpty
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                    if (_isEditing)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4, right: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 4,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                final dialogController =
                                    TextEditingController(
                                        text: _imageController.text);
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  title: const Text('Hình ảnh',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  content: TextField(
                                    controller: dialogController,
                                    decoration: InputDecoration(
                                      hintText: 'Đường dẫn ảnh',
                                      filled: true,
                                      fillColor: Colors.grey.withOpacity(0.1),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Huỷ',
                                          style:
                                              TextStyle(color: Colors.grey)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _imageController.text =
                                              dialogController.text.trim();
                                        });
                                        Navigator.pop(ctx);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                      child: const Text('Đồng ý',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.camera_alt_rounded,
                                size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${_firstNameController.text} ${_lastNameController.text}',
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Text(
                '@${user.username}',
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _isEditing
                        ? _buildEditableInfoItem(
                            isDark: isDark,
                            icon: Icons.person_outline_rounded,
                            title: 'Tên',
                            controller: _firstNameController,
                            validator: (v) =>
                                v!.isEmpty ? 'Vui lòng nhập Tên' : null,
                          )
                        : _buildReadOnlyInfoItem(
                            isDark: isDark,
                            icon: Icons.person_outline_rounded,
                            title: 'Tên',
                            value: _firstNameController.text,
                          ),
                    _isEditing
                        ? _buildEditableInfoItem(
                            isDark: isDark,
                            icon: Icons.person_outline_rounded,
                            title: 'Họ',
                            controller: _lastNameController,
                            validator: (v) =>
                                v!.isEmpty ? 'Vui lòng nhập Họ' : null,
                          )
                        : _buildReadOnlyInfoItem(
                            isDark: isDark,
                            icon: Icons.person_outline_rounded,
                            title: 'Họ',
                            value: _lastNameController.text,
                          ),
                    _isEditing
                        ? _buildEditableInfoItem(
                            isDark: isDark,
                            icon: Icons.email_rounded,
                            title: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v!.isEmpty) return 'Vui lòng nhập Email';
                              final emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(v))
                                return 'Email không hợp lệ';
                              return null;
                            },
                          )
                        : _buildReadOnlyInfoItem(
                            isDark: isDark,
                            icon: Icons.email_rounded,
                            title: 'Email',
                            value: _emailController.text,
                          ),
                    _isEditing
                        ? _buildDropdownInfoItem(
                            isDark: isDark,
                            icon: Icons.wc_rounded,
                            title: 'Giới tính',
                            value: _selectedGender,
                            items: const [
                              DropdownMenuItem(
                                  value: 'male', child: Text('Nam')),
                              DropdownMenuItem(
                                  value: 'female', child: Text('Nữ')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedGender = val);
                              }
                            },
                          )
                        : _buildReadOnlyInfoItem(
                            isDark: isDark,
                            icon: Icons.wc_rounded,
                            title: 'Giới tính',
                            value: _selectedGender == 'female' ? 'Nữ' : 'Nam',
                          ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableInfoItem({
    required bool isDark,
    required IconData icon,
    required String title,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: title,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.grey),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 24),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        ),
      ),
    );
  }

  Widget _buildDropdownInfoItem({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          labelText: title,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.grey),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 24),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        ),
        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildReadOnlyInfoItem({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.grey, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

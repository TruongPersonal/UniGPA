import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/features/auth/providers/auth_provider.dart';
import 'package:unigpa/features/home/screens/main_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _loginFormKey = GlobalKey<FormState>();
  final _loginUsernameCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  bool _loginPasswordVisible = false;

  final _regFormKey = GlobalKey<FormState>();
  final _regFirstNameCtrl = TextEditingController();
  final _regLastNameCtrl = TextEditingController();
  final _regUsernameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmPasswordCtrl = TextEditingController();
  bool _regPasswordVisible = false;
  bool _regConfirmPasswordVisible = false;
  String _regGender = 'male';
  DateTime? _regBirthDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginUsernameCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regFirstNameCtrl.dispose();
    _regLastNameCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _loginUsernameCtrl.text.trim(),
      _loginPasswordCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar('Đăng nhập thành công! Chào mừng đến với UniGPA 🎓',
          isError: false);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainDashboardScreen()),
        (route) => false,
      );
    } else {
      _showSnackBar(auth.error ?? 'Đăng nhập thất bại', isError: true);
    }
  }

  Future<void> _onRegister() async {
    if (!_regFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      firstName: _regFirstNameCtrl.text.trim(),
      lastName: _regLastNameCtrl.text.trim(),
      username: _regUsernameCtrl.text.trim(),
      password: _regPasswordCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar('Đăng ký thành công! Hãy đăng nhập.', isError: false);
      _tabController.animateTo(0);
    } else {
      _showSnackBar(auth.error ?? 'Đăng ký thất bại', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _regBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Chọn ngày sinh',
      cancelText: 'Huỷ',
      confirmText: 'Chọn',
    );
    if (picked != null) setState(() => _regBirthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF311B92)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -80, left: -50,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(Icons.school_rounded,
                              size: 44, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'UniGPA',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quản lý điểm số thông minh',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.75),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF121212) : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, -10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              width: 36, height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const SizedBox.shrink(),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildLoginTab(isLoading, isDark),
                                  _buildRegisterTab(isLoading, isDark),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginTab(bool isLoading, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Chào mừng trở lại!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Đăng nhập để tiếp tục quản lý điểm số.',
                style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13)),
            const SizedBox(height: 22),
            _buildInput(
              controller: _loginUsernameCtrl,
              label: 'Tên đăng nhập',
              icon: Icons.person_outline_rounded,
              isDark: isDark,
              validator: (v) =>
                  v!.isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
            ),
            const SizedBox(height: 12),
            _buildInput(
              controller: _loginPasswordCtrl,
              label: 'Mật khẩu',
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              obscure: !_loginPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _loginPasswordVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey, size: 20,
                ),
                onPressed: () => setState(
                    () => _loginPasswordVisible = !_loginPasswordVisible),
              ),
              validator: (v) =>
                  v!.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
            ),
            const SizedBox(height: 22),
            _buildPrimaryButton(
                label: 'Đăng nhập', isLoading: isLoading, onPressed: _onLogin),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => _tabController.animateTo(1),
                child: RichText(
                  text: TextSpan(
                    text: 'Chưa có tài khoản? ',
                    style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 13),
                    children: const [
                      TextSpan(
                        text: 'Đăng ký ngay',
                        style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTab(bool isLoading, bool isDark) {
    final birthDateText = _regBirthDate != null
        ? '${_regBirthDate!.day.toString().padLeft(2, '0')}/${_regBirthDate!.month.toString().padLeft(2, '0')}/${_regBirthDate!.year}'
        : 'Ngày sinh';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Form(
        key: _regFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _tabController.animateTo(0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: Color(0xFF1565C0)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Tạo tài khoản mới',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Điền thông tin để bắt đầu hành trình!',
                style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    controller: _regFirstNameCtrl,
                    label: 'Họ',
                    icon: Icons.person_outline_rounded,
                    isDark: isDark,
                    validator: (v) => v!.isEmpty ? 'Nhập họ' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInput(
                    controller: _regLastNameCtrl,
                    label: 'Tên',
                    icon: Icons.person_outline_rounded,
                    isDark: isDark,
                    validator: (v) => v!.isEmpty ? 'Nhập tên' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInput(
              controller: _regUsernameCtrl,
              label: 'Tên đăng nhập',
              icon: Icons.alternate_email_rounded,
              isDark: isDark,
              validator: (v) =>
                  v!.isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
            ),
            const SizedBox(height: 12),
            _buildInput(
              controller: _regEmailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v!.isEmpty) return 'Vui lòng nhập email';
                final emailRegex =
                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(v)) return 'Email không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF7F9FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.withOpacity(0.15),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _regGender,
                        isExpanded: true,
                        dropdownColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'male',
                            child: Row(children: [
                              Icon(Icons.male_rounded,
                                  color: Colors.blueAccent, size: 18),
                              const SizedBox(width: 6),
                              const Text('Nam'),
                            ]),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Row(children: [
                              Icon(Icons.female_rounded,
                                  color: Colors.pinkAccent, size: 18),
                              const SizedBox(width: 6),
                              const Text('Nữ'),
                            ]),
                          ),
                        ],
                        onChanged: (v) => setState(() => _regGender = v!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickBirthDate,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFF7F9FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.grey.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: const Color(0xFF1565C0), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              birthDateText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _regBirthDate != null
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInput(
              controller: _regPasswordCtrl,
              label: 'Mật khẩu',
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              obscure: !_regPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _regPasswordVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey, size: 18,
                ),
                onPressed: () =>
                    setState(() => _regPasswordVisible = !_regPasswordVisible),
              ),
              validator: (v) => v!.length < 6 ? 'Ít nhất 6 ký tự' : null,
            ),
            const SizedBox(height: 12),
            _buildInput(
              controller: _regConfirmPasswordCtrl,
              label: 'Xác nhận mật khẩu',
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              obscure: !_regConfirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _regConfirmPasswordVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey, size: 18,
                ),
                onPressed: () => setState(() =>
                    _regConfirmPasswordVisible = !_regConfirmPasswordVisible),
              ),
              validator: (v) {
                if (v!.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                if (v != _regPasswordCtrl.text) return 'Mật khẩu không khớp';
                return null;
              },
            ),
            const SizedBox(height: 22),
            _buildPrimaryButton(
                label: 'Tạo tài khoản',
                isLoading: isLoading,
                onPressed: _onRegister),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => _tabController.animateTo(0),
                child: RichText(
                  text: TextSpan(
                    text: 'Đã có tài khoản? ',
                    style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 13),
                    children: const [
                      TextSpan(
                        text: 'Đăng nhập',
                        style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1565C0), size: 18),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F9FF),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        isDense: true,
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: const Color(0xFF1565C0).withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
      ),
    );
  }
}

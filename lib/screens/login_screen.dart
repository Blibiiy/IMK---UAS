import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/role_toggle_button.dart';
import '../widgets/custom_login_button.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super. key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedRole = 'Mahasiswa';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.login(email: email, password: password);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      final user = userProvider.currentUser;
      if (user?.role == 'dosen') {
        Navigator.pushReplacementNamed(context, '/lecturer-home');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.errorMessage ?? 'Login gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context). colorScheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primaryContainer, cs.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 20),
                RoleToggleButton(
                  selectedRole: _selectedRole,
                  onRoleChanged: (String newRole) =>
                      setState(() => _selectedRole = newRole),
                ),
                const SizedBox(height: 40),
                // CHANGED: Logo jadi bulat dengan shadow
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        'assets/images/SplashImage.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                _buildField(
                  context,
                  label: 'EMAIL',
                  controller: _emailController,
                  hint: 'Contoh: isra@student.com',
                ),
                const SizedBox(height: 16),
                _buildField(
                  context,
                  label: 'PASSWORD',
                  controller: _passwordController,
                  obscure: true,
                  hint: 'Masukkan password',
                ),
                const SizedBox(height: 8),
                Text(
                  'Demo: isra@student.com / aldi@student.com / budi.santoso@lecturer.com',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomLoginButton(onPressed: _handleLogin),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    String? hint,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors. grey[400],
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}
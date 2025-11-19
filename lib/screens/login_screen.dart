import 'package:flutter/material.dart';
import '../widgets/role_toggle_button.dart';
import '../widgets/custom_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedRole = 'Mahasiswa';
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_selectedRole == 'Dosen') {
      Navigator.pushNamed(context, '/lecturer-home');
    } else {
      Navigator.pushNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
                  onRoleChanged: (String newRole) => setState(() => _selectedRole = newRole),
                ),
                const SizedBox(height: 40),
                Image.asset('assets/images/SplashImage.png', width: 140, height: 140),
                const SizedBox(height: 36),
                _buildField(
                  context,
                  label: _selectedRole == 'Mahasiswa' ? 'NIM' : 'NIP',
                  controller: _idController,
                ),
                const SizedBox(height: 16),
                _buildField(
                  context,
                  label: 'PASSWORD',
                  controller: _passwordController,
                  obscure: true,
                ),
                const SizedBox(height: 32),
                CustomLoginButton(onPressed: _handleLogin),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context,
      {required String label, required TextEditingController controller, bool obscure = false}) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
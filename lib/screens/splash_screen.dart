import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme. of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: AppTheme.headerDecoration(cs),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment. center,
            children: [
              // CHANGED: Logo jadi bulat dengan shadow
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/images/SplashImage.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'UNIWORK',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: cs.onPrimary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 80),
              Text(
                'VER 1.0',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cs.onPrimary.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
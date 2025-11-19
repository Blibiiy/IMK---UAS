import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/project_provider.dart';
import 'providers/portfolio_provider.dart';

import 'theme/app_theme.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/project_detail_screen.dart';

import 'screens/lecturer_home_screen.dart';
import 'screens/lecturer_profile_screen.dart';
import 'screens/lecturer_project_detail_screen.dart';
import 'screens/lecturer_add_project_screen.dart';
import 'screens/lecturer_edit_project_screen.dart';
import 'screens/lecturer_members_screen.dart';
import 'screens/lecturer_applicants_screen.dart';

import 'screens/chat_list_screen.dart';
import 'screens/chat_detail_screen.dart';

import 'screens/portfolio_detail_screen.dart';
import 'screens/portfolio_form_screen.dart';
import 'screens/student_profile_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
      ],
      child: MaterialApp(
        title: 'UniWork',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),

          // Mahasiswa
          '/home': (_) => const HomeScreen(),
          '/profile': (_) => const ProfileScreen(),

          // Dosen
          '/lecturer-home': (_) => const LecturerHomeScreen(),
          '/lecturer-profile': (_) => const LecturerProfileScreen(),
          '/lecturer-add-project': (_) => const LecturerAddProjectScreen(),

          // Chat
          '/chat-list': (_) => const ChatListScreen(),
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // NEW: For locale initialization

import 'providers/project_provider.dart';
import 'providers/portfolio_provider.dart';
import 'providers/user_provider.dart';
import 'providers/chat_provider.dart';
import 'config/supabase_config.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NEW: Initialize date formatting dengan locale Indonesia
  // Ini opsional - jika ingin format tanggal dalam Bahasa Indonesia
  try {
    await initializeDateFormatting('id_ID', null);
    print('✅ Date formatting initialized (id_ID)');
  } catch (e) {
    print('⚠️ Failed to initialize id_ID locale, using default: $e');
    // Fallback: app tetap jalan dengan locale default (English)
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('⚠️ Supabase initialization failed: $e');
    print('⚠️ Aplikasi akan menggunakan data dummy');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
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
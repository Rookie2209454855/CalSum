import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calsum_flutter/services/auth_service.dart';
import 'package:calsum_flutter/views/login_page.dart';
import 'package:calsum_flutter/views/home_page.dart';
import 'package:calsum_flutter/theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const CalSumApp(),
    ),
  );
}

class CalSumApp extends StatelessWidget {
  const CalSumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalSum',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          return authService.isAuthenticated ? const HomePage() : const LoginPage();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация внедрения зависимостей (GetIt: Dio, Interceptors, ApiService)
  setupServiceLocator();

  runApp(const NinjasHubApp());
}

class NinjasHubApp extends StatelessWidget {
  const NinjasHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ninja Discovery Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

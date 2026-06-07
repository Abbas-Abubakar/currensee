
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:currensee/services/alerts_service.dart';
import 'package:currensee/providers/profile_provider.dart';
import 'package:currensee/firebase_options.dart';
import 'package:currensee/core/theme/app_theme.dart';
import 'package:currensee/providers/auth_provider.dart';
import 'package:currensee/screens/login_screen.dart';
import 'package:currensee/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WebViewPlatform.instance = AndroidWebViewPlatform();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local notifications
  final alertsService = AlertsService();
  await alertsService.initNotifications();

  // Request notification permission (Android 13+)
  await Permission.notification.request();

  runApp(
    const ProviderScope(
      child: CurrenSeeApp(),
    ),
  );
}

class CurrenSeeApp extends ConsumerWidget {
  const CurrenSeeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    // Load saved preferences
    ref.watch(preferencesLoaderProvider);

    return MaterialApp(
      title: 'CurrenSee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: authState.when(
        data: (user) {
          if (user != null)return const HomeScreen();

          return const LoginScreen();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const LoginScreen(),
      ),
    );
  }
}

import 'package:currensee/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/firebase_options.dart';
import 'package:currensee/core/theme/app_theme.dart';
import 'package:currensee/providers/auth_provider.dart';
import 'package:currensee/screens/login_screen.dart';

// We'll add the home screen import later
// import 'package:currensee/features/conversion/view/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

    return MaterialApp(
      title: 'CurrenSee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const HomeScreen();
          }
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
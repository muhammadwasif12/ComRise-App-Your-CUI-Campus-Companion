import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comrise_cui/core/routing/app_routes.dart';
import 'package:comrise_cui/features/splash/presentation/views/splash_screen.dart';
import 'package:device_preview/device_preview.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:comrise_cui/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ProviderScope(
      child: DevicePreview(enabled: false, builder: (context) => MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'ComRise CUI',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.generateRoute,

      // Dark theme only
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF1A1A2E),
        scaffoldBackgroundColor: const Color(0xFF0F0F1E),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF1A1A2E),
          secondary: const Color(0xFF3498DB),
          surface: const Color(0xFF16213E),
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}

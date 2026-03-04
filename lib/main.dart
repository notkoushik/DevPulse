import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/auth_gate.dart';
import 'data/api_repository.dart';
import 'data/data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://jubdkfqkgknarnzebjdf.supabase.co',
    anonKey: 'sb_publishable_8eQ5wtaV6ZvseruXHWZPWw_PmRHxX-w',
  );

  // Load persisted server URL
  final prefs = await SharedPreferences.getInstance();
  final savedUrl = prefs.getString('server_base_url') ?? 'http://192.168.1.204:3001/api';

  // Attempt to set high refresh rate on Android
  if (Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      // Ignore if device doesn't support it or not available
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => DataProvider(
            repository: ApiDataRepository(
              baseUrl: savedUrl,
            ),
          ),
        ),
      ],
      child: const DevPulseApp(),
    ),
  );
}

class DevPulseApp extends StatelessWidget {
  const DevPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return AppTheme(
      dpTheme: themeProvider.dpTheme,
      child: MaterialApp(
        title: 'DevPulse',
        debugShowCheckedModeBanner: false,
        theme: themeProvider.themeData,
        home: const AuthGate(),
      ),
    );
  }
}

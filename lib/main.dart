import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/auth_gate.dart';
import 'data/api_repository.dart';
import 'data/data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Load persisted server URL or fallback to env var
  final prefs = await SharedPreferences.getInstance();
  final defaultUrl = dotenv.env['API_BASE_URL'] ?? 'https://devpulse-8gkb.onrender.com/api';
  final savedUrl = prefs.getString('server_base_url') ?? defaultUrl;

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

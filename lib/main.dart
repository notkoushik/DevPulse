import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/main_screen.dart';
import 'data/repository.dart';
import 'data/data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
          create: (_) => DataProvider(repository: MockDataRepository()),
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
        home: const MainScreen(),
      ),
    );
  }
}

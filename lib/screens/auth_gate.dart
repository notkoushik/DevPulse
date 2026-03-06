import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/data_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'profile_setup_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _dataLoaded = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        if (session != null) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: Supabase.instance.client
                .from('profiles')
                .select('github_username')
                .eq('id', session.user.id)
                .maybeSingle(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Load data once when we know they're fully set up
              if (!_dataLoaded && profileSnapshot.hasData && profileSnapshot.data?['github_username'] != null) {
                _dataLoaded = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<DataProvider>().loadAllData();
                });
              }

              // Route based on profile existence
              if (profileSnapshot.hasData && profileSnapshot.data?['github_username'] != null) {
                return const MainScreen();
              } else {
                return ProfileSetupScreen(user: session.user);
              }
            },
          );
        }

        // Reset flag when user logs out so next login triggers reload
        _dataLoaded = false;
        return const LoginScreen();
      },
    );
  }
}

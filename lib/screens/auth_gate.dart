import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/data_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';

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
          // Trigger data load once when session becomes valid
          if (!_dataLoaded) {
            _dataLoaded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<DataProvider>().loadAllData();
            });
          }
          return const MainScreen();
        }

        // Reset flag when user logs out so next login triggers reload
        _dataLoaded = false;
        return const LoginScreen();
      },
    );
  }
}

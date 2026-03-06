import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../data/data_provider.dart';
import 'main_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final User user;

  const ProfileSetupScreen({super.key, required this.user});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _githubController = TextEditingController();
  final _leetcodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If they used GitHub OAuth, we can extract their username automatically!
    final identities = widget.user.identities;
    if (identities != null && identities.isNotEmpty) {
      final githubIdentity = identities.firstWhere(
        (id) => id.provider == 'github',
        orElse: () => const UserIdentity(id: '', userId: '', identityData: {}, provider: '', createdAt: '', updatedAt: '', identityId: '', lastSignInAt: ''),
      );
      if (githubIdentity.provider == 'github' && githubIdentity.identityData != null) {
        final username = githubIdentity.identityData!['user_name'];
        if (username != null) {
          _githubController.text = username.toString();
        }
      }
    }
  }

  Future<void> _submitProfile() async {
    final githubUser = _githubController.text.trim();
    final leetcodeUser = _leetcodeController.text.trim();

    if (githubUser.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GitHub username is required!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upsert profile data
      await Supabase.instance.client.from('profiles').upsert({
        'id': widget.user.id,
        'github_username': githubUser,
        'leetcode_username': leetcodeUser.isNotEmpty ? leetcodeUser : null,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      // Force data provider to reload
      context.read<DataProvider>().loadAllData();

      // Navigate to MainScreen, removing setup from backstack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.bg,
                    isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF0F5FA),
                  ],
                ),
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Profile',
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 40,
                        fontStyle: FontStyle.italic,
                        color: theme.text,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.2),
                    const SizedBox(height: 8),
                    Text(
                      'Just two quick handles to build your developer dashboard.',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textMuted,
                        height: 1.4,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 40),

                    // GitHub Field
                    Text('GitHub Username *', style: TextStyle(color: theme.text, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _githubController,
                      style: TextStyle(color: theme.text),
                      decoration: InputDecoration(
                        hintText: 'e.g. torvalds',
                        hintStyle: TextStyle(color: theme.textGhost),
                        prefixIcon: Icon(Icons.code, color: theme.textMuted),
                        filled: true,
                        fillColor: theme.fill2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    const SizedBox(height: 24),

                    // LeetCode Field
                    Text('LeetCode Username (Optional)', style: TextStyle(color: theme.text, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _leetcodeController,
                      style: TextStyle(color: theme.text),
                      decoration: InputDecoration(
                        hintText: 'e.g. algorithm_master',
                        hintStyle: TextStyle(color: theme.textGhost),
                        prefixIcon: Icon(Icons.terminal, color: theme.textMuted),
                        filled: true,
                        fillColor: theme.fill2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DevPulseColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Finish Setup ->',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _githubController.dispose();
    _leetcodeController.dispose();
    super.dispose();
  }
}

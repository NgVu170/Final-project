import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Logic/Authentication/auth_cubit.dart';
import '../../../Logic/Theme/theme_cubit.dart';

class ProfileScreen extends StatelessWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  // --- 1. SHOW USER PROFILE DIALOG ---
  void _showUserProfileDialog(BuildContext context) {
    final user = context.read<AuthCubit>().state as Authenticated;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Display Name: ${user.user.displayName ?? "Not set"}'),
            const SizedBox(height: 8),
            Text('Email: ${user.user.email ?? "No email"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // --- 2. SHOW THEME CHOOSER DIALOG ---
  void _showThemeChooserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Modern'),
              onTap: () {
                context.read<ThemeCubit>().changeTheme(AppThemeType.modern);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Dark'),
              onTap: () {
                context.read<ThemeCubit>().changeTheme(AppThemeType.dark);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Earthy'),
              onTap: () {
                context.read<ThemeCubit>().changeTheme(AppThemeType.earthy);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -- User Profile Button --
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Show User Profile'),
              onPressed: () => _showUserProfileDialog(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // -- Change Theme Button --
            ElevatedButton.icon(
              icon: const Icon(Icons.palette),
              label: const Text('Change Theme'),
              onPressed: () => _showThemeChooserDialog(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 32),

            const Spacer(), // Pushes the sign out button to the bottom

            // -- Sign Out Button --
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Sign Out',
                  style: TextStyle(color: Colors.white)),
              onPressed: () {
                context.read<AuthCubit>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

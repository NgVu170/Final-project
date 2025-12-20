import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Logic
import '../../../Logic/Authentication/auth_cubit.dart';
import '../../../Logic/Theme/theme_cubit.dart';

class ProfileScreen extends StatelessWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final authState = context.watch<AuthCubit>().state;
    String email = "Guest";
    String displayName = "User";
    String initial = "G";

    if (authState is Authenticated) {
      email = authState.user.email ?? "User";
      displayName = authState.user.displayName ?? email.split('@')[0];
      if (displayName.isNotEmpty) initial = displayName[0].toUpperCase();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // --- 1. HEADER USER INFO ---
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.primaryColor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.primaryColor.withOpacity(0.2),
                      child: Text(
                        initial,
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    email,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- 2. SETTINGS LIST ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    return ListView(
                      children: [
                        _buildSectionTitle(context, "APPEARANCE"),
                        const SizedBox(height: 10),

                        // --- THEME SELECTION ---
                        // Hiển thị 3 lựa chọn dựa trên AppThemeType trong file theme_cubit.dart
                        _buildThemeOption(
                          context,
                          title: "Modern (Light)",
                          type: AppThemeType.modern,
                          currentType: state.activeThemeType,
                          icon: Icons.wb_sunny_outlined,
                        ),
                        _buildThemeOption(
                          context,
                          title: "Dark Mode",
                          type: AppThemeType.dark,
                          currentType: state.activeThemeType,
                          icon: Icons.dark_mode_outlined,
                        ),
                        _buildThemeOption(
                          context,
                          title: "Earthy",
                          type: AppThemeType.earthy,
                          currentType: state.activeThemeType,
                          icon: Icons.nature_people_outlined,
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        _buildSectionTitle(context, "ACCOUNT"),
                        const SizedBox(height: 10),

                        // --- LOGOUT ---
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.logout_rounded, color: Colors.red),
                          ),
                          title: Text(
                            "Log Out",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                          onTap: () {
                            // Gọi hàm logout từ AuthCubit
                            context.read<AuthCubit>().signOut();
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tiêu đề section nhỏ
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).primaryColor,
        letterSpacing: 1.2,
      ),
    );
  }

  // Widget hiển thị một dòng chọn Theme
  Widget _buildThemeOption(
      BuildContext context, {
        required String title,
        required AppThemeType type,
        required AppThemeType currentType,
        required IconData icon,
      }) {
    final isSelected = type == currentType;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        // Nếu được chọn thì tô màu nền nhẹ, không thì trong suốt
        color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: theme.primaryColor.withOpacity(0.5))
            : Border.all(color: Colors.transparent),
      ),
      child: ListTile(
        onTap: () {
          context.read<ThemeCubit>().changeTheme(type);
        },
        leading: Icon(
          icon,
          color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.primaryColor)
            : const SizedBox.shrink(),
      ),
    );
  }
}
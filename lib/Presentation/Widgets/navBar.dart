import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 80, // A bit of extra height for aesthetics
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, icon: Icons.home_filled, label: 'Home', index: 0),
          _buildNavItem(context, icon: Icons.note_add, label: 'New Note', index: 1),
          _buildNavItem(context, icon: Icons.folder_shared, label: 'Folders', index: 2),
          _buildNavItem(context, icon: Icons.person, label: 'Profile', index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required int index}) {
    final theme = Theme.of(context);
    final isSelected = currentIndex == index;

    // Use the theme's primary color for the selected item, otherwise use a less prominent color
    final color = isSelected ? theme.colorScheme.primary : theme.iconTheme.color?.withOpacity(0.6);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        // Use a transparent splash color for a cleaner effect
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

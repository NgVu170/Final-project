import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, icon: Icons.home_filled, index: 0),
          _buildNavItem(context, icon: Icons.folder_open, index: 1),

          GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: theme.primaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                  ]
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),

          _buildNavItem(context, icon: Icons.archive_outlined, index: 3),
          _buildNavItem(context, icon: Icons.person_outline, index: 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required int index}) {
    final theme = Theme.of(context);
    final isSelected = currentIndex == index;

    return IconButton(
      icon: Icon(
          icon,
          color: isSelected ? theme.primaryColor : Colors.grey, // Đổi màu nếu được chọn
          size: 28
      ),
      onPressed: () => onTap(index),
    );
  }
}
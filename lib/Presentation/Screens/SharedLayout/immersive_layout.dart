import 'package:flutter/material.dart';

class ImmersiveLayout extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onTabTapped;
  final Widget? floatingActionButton;

  const ImmersiveLayout({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTabTapped,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Folders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

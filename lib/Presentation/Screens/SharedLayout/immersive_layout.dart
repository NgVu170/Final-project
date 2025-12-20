import 'package:flutter/material.dart';
import 'immersive_editor.dart';

import '../../Widgets/navBar.dart';
import '../../Widgets/searchBar.dart';

class ImmersiveLayout extends StatefulWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onTabTapped;
  final Function(String)? onSearch;
  final Widget? floatingActionButton;

  const ImmersiveLayout({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTabTapped,
    this.onSearch,
    this.floatingActionButton,
  });

  @override
  State<ImmersiveLayout> createState() => _ImmersiveLayoutState();
}

class _ImmersiveLayoutState extends State<ImmersiveLayout> {
  bool _showUI = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: NotificationListener<ToggleNavbarNotification>(
        onNotification: (notification) {
          setState(() {
            _showUI = !_showUI;
          });
          return true;
        },
        child: Stack(
          children: [
            // 1. BODY
            Positioned.fill(
              child: widget.body,
            ),

            // 2. SEARCH BAR
            if (widget.onSearch != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: _showUI ? 50 : -150,
                left: 16,
                right: 16,
                child: CustomSearchBar(onChanged: widget.onSearch!),
              ),

            // 3. NAV BAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _showUI ? 0 : -100,
              left: 0,
              right: 0,
              child: CustomNavBar(
                currentIndex: widget.currentIndex,
                onTap: widget.onTabTapped,
              ),
            ),

            // 4. FLOATING ACTION BUTTON
            if (widget.floatingActionButton != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: _showUI ? 100 : -100,
                right: 24,
                child: widget.floatingActionButton!,
              ),
          ],
        ),
      ),
    );
  }
}
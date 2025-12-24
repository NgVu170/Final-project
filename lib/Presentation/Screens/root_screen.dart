import 'package:flutter/material.dart';
import 'package:note_app_using_para/Presentation/Widgets/navBar.dart';
import 'AppUser/home_screen.dart';
import 'Profile/profile_screen.dart';
import 'Editor/note_editor_screen.dart';
import 'Folder/folder_screen.dart';

// The RootScreen now acts as your primary screen or "Home Page".
class RootScreen extends StatefulWidget {
  final String uid;
  const RootScreen({super.key, required this.uid});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  // The _currentIndex now represents the tab on THIS screen's navbar.
  // We will set it to 0 for "Home".
  int _currentIndex = 0;

  // DEFINITIVE FIX: Switched from IndexedStack to simple push/pop navigation.
  void _onTabTapped(int index) {
    // If the user taps the tab they are already on, do nothing.
    if (_currentIndex == index) return;

    switch (index) {
      case 0: // Home - This is the current screen, so we do nothing.
        // In a real app, you might want to scroll to the top or refresh.
        break;
      case 1: // New Note
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => NoteEditorScreen(uid: widget.uid, parentFolderId: 'Root'),
        ));
        break;
      case 2: // Folders
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => FolderScreen(uid: widget.uid),
        ));
        break;
      case 3: // Profile
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ProfileScreen(uid: widget.uid),
        ));
        break;
    }
    // Note: We don't call setState here because this screen itself doesn't rebuild.
    // The state of the active tab is managed by the CustomNavBar.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('This is the Home Screen.', style: TextStyle(fontSize: 24)),
      ),
      // Your CustomNavBar is now the primary navigation driver.
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex, // It always shows "Home" as selected on this screen.
        onTap: _onTabTapped,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:note_app_using_para/Presentation/Widgets/navBar.dart';
import 'AppUser/home_screen.dart';
import 'Profile/profile_screen.dart';
import 'Editor/note_editor_screen.dart';
import 'Folder/folder_screen.dart';

class RootScreen extends StatefulWidget {
  final String uid;
  const RootScreen({super.key, required this.uid});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      // 0: Home Page
      const HomeScreen(uid: '', controller: null, focusNode: null, onSave: null),
      
      // 1: New Note Page
      NoteEditorScreen(uid: widget.uid, parentFolderId: 'Root'),
      
      // 2: Folder Page
      FolderScreen(uid: widget.uid),
      
      // 3: Profile Page
      ProfileScreen(uid: widget.uid),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // DEFINITIVE FIX: Using your CustomNavBar as you intended.
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

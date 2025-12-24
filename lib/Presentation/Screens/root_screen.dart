import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:note_app_using_para/Presentation/Screens/AppUser/home_screen.dart';
import 'package:note_app_using_para/Presentation/Screens/Profile/profile_screen.dart';
import 'Folder/folder_screen.dart';

class RootScreen extends StatelessWidget {
  final String uid;
  const RootScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logic Debug'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('UI has been temporarily removed to focus on logic.\nUser ID: $uid'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FolderScreen(
                      uid: uid,
                      onNoteSelected: (note) {
                        debugPrint("Note selected: ${note.title}");
                      },
                    ),
                  ),
                );
              },
              child: const Text('Test Search Bar on Folder Screen'),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      uid: uid,
                      // Provide dummy values for the required parameters
                      controller: QuillController.basic(),
                      focusNode: FocusNode(),
                      onSave: () {
                        debugPrint("Save button pressed");
                      },
                    ),
                  ),
                );
              },
              child: const Text('Go to Home Screen'),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      uid: uid,
                    ),
                  ),
                );
              },
              child: const Text('Go to Profile Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

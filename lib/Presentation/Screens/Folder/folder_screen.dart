import 'package:flutter/material.dart';
import '../../../Data/Model/note.dart';

class FolderScreen extends StatelessWidget {
  const FolderScreen({
    super.key,
    required String uid,
    required Function(Note) onNoteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Folder Screen placeholder'),
    );
  }
}

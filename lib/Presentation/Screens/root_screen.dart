import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

// Import Widgets
import '../Screens/SharedLayout/immersive_layout.dart';
import 'AppUser/home_screen.dart';
import 'Folder/folder_screen.dart';
import 'Profile/profile_screen.dart';

// Logic
import '../../Logic/Note/note_cubit.dart';
import '../../Data/Model/note.dart';

class RootScreen extends StatefulWidget {
  final String uid; // ĐÂY LÀ SOURCE OF TRUTH
  const RootScreen({super.key, required this.uid});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  late final QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  Note? _currentOpenedNote;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
  }

  @override
  void dispose() {
    _quillController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != 0) _editorFocusNode.unfocus();
    setState(() => _currentIndex = index);
  }

  void _openNoteFromFolder(String content) {
    if (content.isNotEmpty) {
      try {
        final json = jsonDecode(content);
        _quillController.document = Document.fromJson(json);
      } catch (e) {
        _quillController.document = Document()..insert(0, content);
      }
    } else {
      _quillController.document = Document()..insert(0, '');
    }
    setState(() {
      _currentIndex = 0;
      _currentOpenedNote = null;
    });
  }

  void _saveCurrentNote() {
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
    final plainText = _quillController.document.toPlainText().trim();
    String title = "New Note";
    if (plainText.isNotEmpty) {
      final lines = plainText.split('\n');
      if (lines.isNotEmpty && lines[0].trim().isNotEmpty) {
        title = lines[0].trim();
        if (title.length > 50) title = "${title.substring(0, 50)}...";
      }
    }
    if (_currentOpenedNote != null) {
      final updatedNote = _currentOpenedNote!.copyWith(title: title, content: contentJson, updatedAt: DateTime.now());
      context.read<NoteCubit>().updateNote(widget.uid, updatedNote);
    } else {
      context.read<NoteCubit>().addNote(widget.uid, title, contentJson, 'Storage', [], [], []);
    }
    _editorFocusNode.unfocus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved!"), backgroundColor: Theme.of(context).colorScheme.primary));
  }

  Widget? _buildFAB() {
    if (_currentIndex == 1) {
      return FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentIndex = 0;
            _quillController.clear();
            _currentOpenedNote = null;
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.edit, color: Colors.white),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ImmersiveLayout(
      currentIndex: _currentIndex,
      onTabTapped: _onTabTapped,
      onSearch: _currentIndex == 1 ? (query) {} : null,
      floatingActionButton: _buildFAB(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // TRUYỀN UID XUỐNG CÁC CON
          HomeScreen(
            uid: widget.uid,
            controller: _quillController,
            focusNode: _editorFocusNode,
            onSave: _saveCurrentNote,
          ),
          FolderScreen(
            uid: widget.uid,
            onNoteSelected: _openNoteFromFolder,
          ),
          ProfileScreen(
            uid: widget.uid,
          ),
        ],
      ),
    );
  }
}
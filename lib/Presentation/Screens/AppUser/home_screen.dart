import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../Screens/SharedLayout/immersive_editor.dart';

class HomeScreen extends StatelessWidget {
  final String uid; // Nhận UID từ cha
  final QuillController controller;
  final FocusNode focusNode;
  final VoidCallback onSave;

  const HomeScreen({
    super.key,
    required this.uid,
    required this.controller,
    required this.focusNode,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImmersiveEditor(
          controller: controller,
          focusNode: focusNode,
        ),

        Positioned(
          top: 60,
          right: 20,
          child: FloatingActionButton.small(
            heroTag: "save_btn",
            onPressed: onSave,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.check, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
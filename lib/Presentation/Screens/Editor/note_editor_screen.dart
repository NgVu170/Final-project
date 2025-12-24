import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:image_picker/image_picker.dart';
import '../../../Data/Model/note.dart';
import '../../../Logic/Note/note_cubit.dart';
import '../../Widgets/custom_quill_toolbar.dart'; // Import the new custom toolbar

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final String uid;
  final String parentFolderId;

  const NoteEditorScreen({
    super.key, 
    this.note,
    required this.uid,
    this.parentFolderId = 'Root',
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late QuillController _controller;
  late TextEditingController _titleController;
  final FocusNode _editorFocusNode = FocusNode();

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _loadDocument();
  }

  void _loadDocument() {
    if (_isEditing && widget.note!.content.isNotEmpty) {
      try {
        final decoded = jsonDecode(widget.note!.content);
        _controller = QuillController(
          document: Document.fromJson(decoded),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _controller = QuillController(
          document: Document()..insert(0, widget.note!.content),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _controller = QuillController.basic();
    }
  }

  void _saveNote() {
    final jsonContent = jsonEncode(_controller.document.toDelta().toJson());
    final title = _titleController.text.isEmpty ? "Untitled Note" : _titleController.text;

    if (_isEditing) {
      final updatedNote = widget.note!.copyWith(title: title, content: jsonContent);
      context.read<NoteCubit>().updateNote(widget.uid, updatedNote);
    } else {
      context.read<NoteCubit>().addNote(widget.uid, title, jsonContent, widget.parentFolderId, [], [], []);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note Saved!'), backgroundColor: Colors.green),
    );
    if (!_isEditing) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickAndEmbedImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final index = _controller.selection.baseOffset;
      final length = _controller.selection.extentOffset - index;
      _controller.replaceText(index, length, BlockEmbed.image(image.path), null);
    }
  }

  void _insertTag() {
    final index = _controller.selection.baseOffset;
    _controller.document.insert(index, '#');
    _controller.moveCursorToPosition(index + 1);
  }
  
  void _insertLink() {
     // This is a simplified version. A real implementation would show a dialog.
    _controller.document.format(_controller.selection.start, 0, LinkAttribute('https://example.com'));
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DEFINITIVE FIX: Removed the garbage if-statement that I invented.
    // initState is guaranteed to finish before build is called.
    
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration(hintText: 'Note Title', border: InputBorder.none),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.image), onPressed: _pickAndEmbedImage, tooltip: 'Add Image'),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote, tooltip: 'Save Note'),
        ],
      ),
      body: Column(
        children: [
          CustomQuillToolbar(
            controller: _controller,
            onAddTag: _insertTag,
            onAddLink: _insertLink,
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: QuillEditor.basic(
                    controller: _controller,
                    focusNode: _editorFocusNode,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
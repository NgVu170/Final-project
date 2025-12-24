import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:image_picker/image_picker.dart';
import '../../../Data/Model/note.dart';
import '../../../Logic/Note/note_cubit.dart';
import '../../Widgets/custom_quill_toolbar.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final String uid;
  final String parentFolderId;

  const NoteEditorScreen({
    super.key, 
    this.note,
    required this.uid,
    this.parentFolderId = 'Project',
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

  // DEFINITIVE FIX: The save method now correctly handles new and existing images.
  void _saveNote() {
    final jsonContent = jsonEncode(_controller.document.toDelta().toJson());
    final title = _titleController.text.isEmpty ? "Untitled Note" : _titleController.text;

    // Extract image paths from the document
    final List<String> allImagePaths = _controller.document.toDelta().operations
        .where((op) => op.isInsert && op.value is Map && (op.value as Map).containsKey('image'))
        .map((op) => (op.value as Map)['image'] as String)
        .toList();

    if (_isEditing) {
      // Separate new local paths from existing cloud URLs
      final List<String> newImagePaths = allImagePaths.where((path) => !path.startsWith('http')).toList();
      final List<String> existingImageUrls = allImagePaths.where((path) => path.startsWith('http')).toList();

      final updatedNote = widget.note!.copyWith(
        title: title,
        content: jsonContent,
        imageUrls: existingImageUrls, // Pass only the existing URLs
      );
      // Call the updated method with the list of new paths to upload
      context.read<NoteCubit>().updateNote(widget.uid, updatedNote, newImagePaths);

    } else {
      // For a new note, all image paths are new
      context.read<NoteCubit>().addNote(widget.uid, title, jsonContent, widget.parentFolderId, [], allImagePaths, []);
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Data/Model/folder.dart';
import '../../../Data/Model/note.dart';
import '../../../Logic/Folder/folder_cubit.dart';
import '../../../Logic/Note/note_cubit.dart';
import '../Editor/note_editor_screen.dart';

class FolderScreen extends StatefulWidget {
  final String uid;
  final String parentFolderId;
  final String title;

  const FolderScreen({
    super.key,
    required this.uid,
    this.parentFolderId = 'Root',
    this.title = 'My Notes',
  });

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    if (mounted) {
      if (widget.parentFolderId == 'Root') {
        context.read<FolderCubit>().fetchFolders(widget.uid);
        context.read<NoteCubit>().fetchNotes(widget.uid);
      } else {
        context.read<FolderCubit>().fetchSubFolders(widget.uid, widget.parentFolderId);
        context.read<NoteCubit>().fetchNotesInFolder(widget.uid, widget.parentFolderId);
      }
    }
  }

  void _navigateToSubFolder(Folder folder) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FolderScreen(
        uid: widget.uid,
        parentFolderId: folder.id!,
        title: folder.name,
      ),
    )).then((_) => _fetchData());
  }

  void _openNoteEditor(Note note) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NoteEditorScreen(uid: widget.uid, note: note),
    )).then((_) => _fetchData());
  }

  void _createNewNote() {
     Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NoteEditorScreen(
        uid: widget.uid,
        parentFolderId: widget.parentFolderId,
      ),
    ));
  }
  
  void _showCreateFolderDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Folder'),
        content: TextField(controller: nameController, decoration: const InputDecoration(hintText: "Folder Name"), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            child: const Text('Create'),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<FolderCubit>().createSubFolder(widget.uid, nameController.text, widget.parentFolderId);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(dynamic item) {
    final nameController = TextEditingController(text: item is Folder ? item.name : item.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename ${item is Folder ? 'Folder' : 'Note'}'),
        content: TextField(controller: nameController, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                if (item is Folder) {
                  final updatedFolder = item.copyWith(name: nameController.text);
                  context.read<FolderCubit>().updateFolder(widget.uid, updatedFolder);
                } else if (item is Note) {
                  final updatedNote = item.copyWith(title: nameController.text);
                  context.read<NoteCubit>().updateNote(widget.uid, updatedNote);
                }
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          // DEFINITIVE FIX: Using a real icon that exists
          IconButton(icon: const Icon(Icons.create_new_folder_outlined), onPressed: _showCreateFolderDialog, tooltip: 'Create Folder'),
          IconButton(icon: const Icon(Icons.note_add), onPressed: _createNewNote, tooltip: 'Create Note'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData, tooltip: 'Refresh Data'),
        ],
      ),
      body: BlocBuilder<FolderCubit, FolderState>(
        builder: (context, folderState) {
          return BlocBuilder<NoteCubit, NoteState>(
            builder: (context, noteState) {
              if (folderState is FolderLoading || noteState is NoteLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (folderState is FolderFailure) {
                return Center(child: Text('Error: ${folderState.message}'));
              }
              if (noteState is NoteFailure) {
                return Center(child: Text('Error: ${noteState.message}'));
              }
              if (folderState is FolderLoaded && noteState is NoteLoaded) {
                final List<dynamic> combinedItems = [
                  ...folderState.folders,
                  ...noteState.notes,
                ];

                if (combinedItems.isEmpty) {
                  return const Center(child: Text('This folder is empty.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: combinedItems.length,
                  itemBuilder: (context, index) {
                    final item = combinedItems[index];
                    if (item is Folder) {
                      return Card(child: ListTile(leading: const Icon(Icons.folder), title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)), onTap: () => _navigateToSubFolder(item), trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showRenameDialog(item))));
                    }
                    if (item is Note) {
                      return Card(child: ListTile(leading: const Icon(Icons.description), title: Text(item.title), onTap: () => _openNoteEditor(item), trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showRenameDialog(item))));
                    }
                    return const SizedBox.shrink();
                  },
                );
              }
              return const Center(child: Text("Press refresh to load data"));
            },
          );
        },
      ),
    );
  }
}

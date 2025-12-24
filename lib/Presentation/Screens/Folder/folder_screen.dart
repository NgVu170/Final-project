import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Data/Model/folder.dart';
import '../../../Data/Model/note.dart';
import '../../../Logic/Folder/folder_cubit.dart';
import '../../../Logic/Note/note_cubit.dart';

// A reusable screen for displaying the contents of a folder.
class FolderScreen extends StatefulWidget {
  final String uid;
  final String parentFolderId;
  final String title;

  const FolderScreen({
    super.key,
    required this.uid,
    this.parentFolderId = 'Root', // Default to showing the top-level content.
    this.title = 'My Notes',      // Default title for the root view.
  });

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the specific content for THIS folder view.
    _fetchData();
  }

  void _fetchData() {
    if (mounted) {
      context.read<FolderCubit>().fetchSubFolders(widget.uid, widget.parentFolderId);
      context.read<NoteCubit>().fetchNotesInFolder(widget.uid, widget.parentFolderId);
    }
  }

  // --- NAVIGATION ---
  void _navigateToSubFolder(Folder folder) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FolderScreen(
        uid: widget.uid,
        parentFolderId: folder.id!,
        title: folder.name,
      ),
    )).then((_) => _fetchData()); // Refetch data when we return.
  }
  
  void _openNote(Note note) {
    // TODO: Implement navigation to the actual note editor screen.
    debugPrint("Tapped on note: ${note.title}");
  }

  // --- DIALOGS ---
  void _showCreateDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New'),
        content: TextField(controller: nameController, decoration: const InputDecoration(hintText: "Name"), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          // Unified button to create a Folder
          ElevatedButton.icon(
            icon: const Icon(Icons.folder),
            label: const Text('Folder'),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<FolderCubit>().createSubFolder(widget.uid, nameController.text, widget.parentFolderId);
                Navigator.of(context).pop();
              }
            },
          ),
          // Unified button to create a Note
          ElevatedButton.icon(
            icon: const Icon(Icons.note_add),
            label: const Text('Note'),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<NoteCubit>().addNote(widget.uid, nameController.text, '', widget.parentFolderId, [], [], []);
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
          IconButton(icon: const Icon(Icons.add_circle), onPressed: _showCreateDialog, tooltip: 'Create Folder or Note'),
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
                final subFolders = folderState.folders;
                final notesInFolder = noteState.notes;
                
                if (subFolders.isEmpty && notesInFolder.isEmpty) {
                  return const Center(child: Text('This folder is empty. Use the + button to add something.'));
                }

                return ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    // Render folders first
                    ...subFolders.map((folder) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.folder_copy),
                        title: Text(folder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showRenameDialog(folder), tooltip: 'Rename Folder'),
                        onTap: () => _navigateToSubFolder(folder),
                      ),
                    )),
                    // Then render notes
                    ...notesInFolder.map((note) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.description),
                        title: Text(note.title),
                        trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showRenameDialog(note), tooltip: 'Rename Note'),
                        onTap: () => _openNote(note),
                      ),
                    )),
                  ],
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

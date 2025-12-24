import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Core/Constants/SearchBar/search_type.dart';
import '../../../Data/Model/note.dart';
import '../../../Data/Model/folder.dart';
import '../../../Logic/Folder/folder_cubit.dart';
import '../../../Logic/Note/note_cubit.dart';
import '../../Widgets/searchBar.dart';

class FolderScreen extends StatefulWidget {
  final String uid;
  final Function(Note) onNoteSelected;

  const FolderScreen({
    super.key,
    required this.uid,
    required this.onNoteSelected,
  });

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  Timer? _debounce;
  String _searchQuery = '';
  SearchType _searchType = SearchType.content;
  SortOrder _sortOrder = SortOrder.ascending;

  @override
  void initState() {
    super.initState();
    // Fetch data on screen load
    _fetchData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _fetchData() {
    if (mounted) {
      context.read<NoteCubit>().fetchNotes(widget.uid);
      context.read<FolderCubit>().fetchFolders(widget.uid);
    }
  }

  // --- Dialogs for Creating New Items ---
  void _showCreateFolderDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Folder"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Folder Name")),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<FolderCubit>().createSubFolder(widget.uid, controller.text, "Root");
                Navigator.of(context).pop();
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showCreateNoteDialog(String folderId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Note"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Note Title")),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<NoteCubit>().addNote(widget.uid, controller.text, "", folderId, [], [], []);
                Navigator.of(context).pop();
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text('My Notes'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.create_new_folder), onPressed: _showCreateFolderDialog, tooltip: 'Create Folder'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData, tooltip: 'Refresh'),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            // Assuming CustomSearchBar exists and is correctly implemented
            // child: CustomSearchBar(...),
          ),
          Expanded(
            child: BlocBuilder<FolderCubit, FolderState>(
              builder: (context, folderState) {
                return BlocBuilder<NoteCubit, NoteState>(
                  builder: (context, noteState) {
                    if (folderState is FolderLoading || noteState is NoteLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (folderState is FolderFailure) {
                      return Center(child: Text('Error loading folders: ${folderState.message}'));
                    }
                    if (noteState is NoteFailure) {
                      return Center(child: Text('Error loading notes: ${noteState.message}'));
                    }
                    if (folderState is FolderLoaded && noteState is NoteLoaded) {
                      final folders = folderState.folders;
                      final notes = noteState.notes;

                      if (folders.isEmpty) {
                        return const Center(child: Text('No folders found. Press the + folder icon to create one.'));
                      }

                      return ListView.builder(
                        itemCount: folders.length,
                        itemBuilder: (context, index) {
                          final folder = folders[index];
                          final notesInFolder = notes.where((note) => note.parentFolderId == folder.id).toList();

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ExpansionTile(
                              title: Text(folder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${notesInFolder.length} notes'),
                              children: [
                                ...notesInFolder.map((note) => ListTile(
                                  title: Text(note.title),
                                  onTap: () => widget.onNoteSelected(note),
                                )),
                                // Add Note button at the bottom of each folder
                                ListTile(
                                  leading: const Icon(Icons.add, color: Colors.blueAccent),
                                  title: const Text("Add Note", style: TextStyle(color: Colors.blueAccent)),
                                  onTap: () => _showCreateNoteDialog(folder.id!),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

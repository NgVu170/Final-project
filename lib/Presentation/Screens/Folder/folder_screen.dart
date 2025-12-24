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
    // We are intentionally NOT fetching data automatically anymore.
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // --- Manual data fetch method ---
  void _fetchData() {
    if (mounted) {
      context.read<NoteCubit>().fetchNotes(widget.uid);
      context.read<FolderCubit>().fetchFolders(widget.uid);
    }
  }

  void _onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _performSearch);
    setState(() {
      _searchQuery = query;
    });
  }

  void _onSearchTypeChanged(SearchType type) {
    setState(() {
      _searchType = type;
    });
    _performSearch();
  }

  void _onSortOrderChanged(SortOrder order) {
    setState(() {
      _sortOrder = order;
    });
    _performSearch();
  }

  void _performSearch() {
    if (mounted) {
      context.read<NoteCubit>().searchNotes(
            _searchQuery,
            _searchType,
            _sortOrder == SortOrder.descending,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('My Notes'),
        centerTitle: true,
        actions: [
          // Add a refresh button to manually trigger the fetch
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Fetch Data',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSearchBar(
              searchQuery: _searchQuery,
              searchType: _searchType,
              sortOrder: _sortOrder,
              onSearchQueryChanged: _onSearchQueryChanged,
              onSearchTypeChanged: _onSearchTypeChanged,
              onSortOrderChanged: _onSortOrderChanged,
            ),
          ),
          Expanded(
            child: BlocBuilder<FolderCubit, FolderState>(
              builder: (context, folderState) {
                return BlocBuilder<NoteCubit, NoteState>(
                  builder: (context, noteState) {
                    if (folderState is FolderInitial || noteState is NoteInitial) {
                      return const Center(
                        child: Text('Press the refresh button to load data.'),
                      );
                    }
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
                        return const Center(child: Text('No folders found.'));
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
                              children: notesInFolder.map((note) => ListTile(
                                title: Text(note.title),
                                onTap: () => widget.onNoteSelected(note),
                              )).toList(),
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

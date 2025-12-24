import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Core/Constants/SearchBar/search_type.dart';
import '../../../Data/Model/note.dart';
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
  // Debouncer timer
  Timer? _debounce;

  // State for the search bar
  String _searchQuery = '';
  SearchType _searchType = SearchType.content;
  SortOrder _sortOrder = SortOrder.ascending;

  @override
  void initState() {
    super.initState();
    // Initial data fetch
    context.read<NoteCubit>().fetchNotes(widget.uid);
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to prevent memory leaks
    _debounce?.cancel();
    super.dispose();
  }

  // --- Callback Methods for the Search Bar ---
  void _onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
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
        // FIX: Add a leading back button to the AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Use Navigator.pop to go back to the previous screen (RootScreen)
            Navigator.of(context).pop();
          },
        ),
        title: const Text('My Notes'),
        centerTitle: true,
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
            child: BlocBuilder<NoteCubit, NoteState>(
              builder: (context, state) {
                if (state is NoteLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is NoteLoaded) {
                  final notes = state.notes;
                  if (notes.isEmpty) {
                    return const Center(child: Text('No notes found.'));
                  }
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(note.title),
                          subtitle: Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => widget.onNoteSelected(note),
                        ),
                      );
                    },
                  );
                }
                if (state is NoteFailure) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const Center(child: Text('Select a folder to see your notes.'));
              },
            ),
          ),
          // FIX: Removed the incorrect button from the bottom
        ],
      ),
    );
  }
}

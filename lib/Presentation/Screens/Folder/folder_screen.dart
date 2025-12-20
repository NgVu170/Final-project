import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// Logic
import '../../../Logic/Folder/folder_cubit.dart';
import '../../../Logic/Note/note_cubit.dart';

// Model
import '../../../Data/Model/folder.dart';
import '../../../Data/Model/note.dart';

class FolderScreen extends StatefulWidget {
  final String uid; // NHẬN UID TỪ ROOT SCREEN
  final Function(String noteContent) onNoteSelected;

  const FolderScreen({
    super.key,
    required this.uid,
    required this.onNoteSelected
  });

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  @override
  void initState() {
    super.initState();
    // Dùng widget.uid để fetch dữ liệu ngay lập tức
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FolderCubit>().fetchFolders(widget.uid);
      context.read<NoteCubit>().fetchNotes(widget.uid);
    });
  }

  // Dialog Tạo Folder
  void _showAddFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text("New Folder", style: TextStyle(color: colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: "Enter folder name...",
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: colorScheme.error)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                // Sử dụng widget.uid
                context.read<FolderCubit>().createSubFolder(widget.uid, controller.text.trim(), "Root");
                Navigator.pop(context);
              }
            },
            child: Text("Create", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Dialog Tạo Note
  void _showAddNoteDialog(BuildContext context, String parentFolderId) {
    final controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text("New Note", style: TextStyle(color: colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: "Enter note title...",
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: colorScheme.error)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                // Sử dụng widget.uid
                context.read<NoteCubit>().addNote(
                    widget.uid,
                    controller.text.trim(),
                    "", // Content
                    parentFolderId,
                    [], [], []
                );
                Navigator.pop(context);
              }
            },
            child: Text("Create", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Dialog Đổi tên Note
  void _showRenameNoteDialog(BuildContext context, Note note) {
    final controller = TextEditingController(text: note.title);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text("Rename Note", style: TextStyle(color: colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: const InputDecoration(hintText: "Enter new title..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: colorScheme.error))),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != note.title) {
                final updatedNote = note.copyWith(title: newTitle);
                // Sử dụng widget.uid
                context.read<NoteCubit>().updateNote(widget.uid, updatedNote);
                Navigator.pop(context);
              }
            },
            child: Text("Save", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("My Knowledge", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.create_new_folder_outlined, color: colorScheme.onSurface),
            tooltip: "Create Folder",
            onPressed: () => _showAddFolderDialog(context),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final folderState = context.watch<FolderCubit>().state;
          final noteState = context.watch<NoteCubit>().state;

          if (folderState is FolderLoading || noteState is NoteLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (folderState is FolderLoaded && noteState is NoteLoaded) {
            final folders = folderState.folders;
            final allNotes = noteState.notes;

            if (folders.isEmpty) {
              return Center(child: Text("No folders found.", style: TextStyle(color: colorScheme.onSurfaceVariant)));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                final notesInThisFolder = allNotes.where((note) => note.parentFolderId == folder.id).toList();
                return _buildFolderCard(context, folder, notesInThisFolder);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFolderCard(BuildContext context, Folder folder, List<Note> notes) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: colorScheme.onSurfaceVariant,
          iconColor: colorScheme.primary,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.folder, color: Colors.amber.shade700, size: 24),
          ),
          title: Text(folder.name ?? "Unnamed", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onSurface, fontSize: 15)),
          subtitle: Text("${notes.length} notes", style: GoogleFonts.poppins(fontSize: 12, color: colorScheme.onSurfaceVariant)),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
            color: colorScheme.surface,
            onSelected: (value) {
              if (value == 'delete') context.read<FolderCubit>().deleteSubFolder(widget.uid, folder);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: colorScheme.error, size: 20), const SizedBox(width: 8), Text("Delete Folder", style: TextStyle(color: colorScheme.error))])),
            ],
          ),
          children: [
            if (notes.isNotEmpty) ...notes.map((note) => _buildNoteItem(context, note)).toList()
            else Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text("Empty folder", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12))),

            Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)))),
              child: ListTile(
                leading: Icon(Icons.add_circle_outline, color: colorScheme.primary, size: 22),
                title: Text("Create new note here", style: GoogleFonts.poppins(color: colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 14)),
                onTap: () => _showAddNoteDialog(context, folder.id!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(BuildContext context, Note note) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 20, right: 8, bottom: 4),
      leading: Icon(Icons.description_outlined, size: 20, color: colorScheme.onSurfaceVariant),
      title: Text(note.title ?? "Untitled", style: GoogleFonts.poppins(fontSize: 14, color: colorScheme.onSurface)),
      onTap: () => widget.onNoteSelected(note.content ?? ""),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_horiz, size: 20, color: colorScheme.onSurfaceVariant),
        color: colorScheme.surface,
        onSelected: (value) {
          if (value == 'rename') {
            _showRenameNoteDialog(context, note);
          } else if (value == 'delete') {
            context.read<NoteCubit>().deleteNote(widget.uid, note);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'rename', child: Row(children: [Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20), const SizedBox(width: 8), Text("Rename", style: TextStyle(color: colorScheme.onSurface))])),
          PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: colorScheme.error, size: 20), const SizedBox(width: 8), Text("Delete", style: TextStyle(color: colorScheme.error))])),
        ],
      ),
    );
  }
}
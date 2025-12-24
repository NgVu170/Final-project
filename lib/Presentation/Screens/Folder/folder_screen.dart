import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import Models & Logic
import '../../../Data/Model/folder.dart';
import '../../../Data/Model/note.dart';
import '../../../Data/Repository/folder_repository.dart';
import '../../../Data/Repository/note_repository.dart';
import '../../../Logic/Folder/folder_cubit.dart';
import '../../../Logic/Note/note_cubit.dart';

import '../Editor/note_editor_screen.dart';

class FolderScreen extends StatelessWidget {
  final String uid;

  const FolderScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    // 1. KHỞI TẠO CUBIT TẠI ĐÂY (ROOT)
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FolderCubit(
            context.read<FolderRepository>(),
            context.read<NoteRepository>(),
          )..initRealtimeData(uid),
        ),
        BlocProvider(
          create: (context) => NoteCubit(context.read<NoteRepository>()),
        ),
      ],
      // Truyền UID xuống widget con
      child: _FolderContent(
        uid: uid,
        parentFolderId: 'Root', // Root là null (hoặc 'Root' tùy DB)
        folderName: "My Notes",
      ),
    );
  }
}

// --- WIDGET NỘI BỘ ---
class _FolderContent extends StatelessWidget {
  final String uid; // [ADD] Cần biến này để truyền cho Editor
  final String? parentFolderId;
  final String folderName;

  const _FolderContent({
    required this.uid,
    required this.parentFolderId,
    required this.folderName,
  });

  // Hàm chuyển trang Folder con
  void _navigateToSubFolder(BuildContext context, Folder folder) {
    final folderCubit = context.read<FolderCubit>();
    final noteCubit = context.read<NoteCubit>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: folderCubit), // Tái sử dụng FolderCubit
            BlocProvider.value(value: noteCubit),   // Tái sử dụng NoteCubit
          ],
          child: _FolderContent(
            uid: uid, // [ADD] Truyền tiếp UID xuống cấp dưới
            parentFolderId: folder.id,
            folderName: folder.name ?? "Folder",
          ),
        ),
      ),
    );
  }

  // [LOGIC MỞ EDITOR]
  void _openNoteEditor(BuildContext context, Note note) {
    // Lấy NoteCubit hiện tại để mang sang màn hình Editor
    final noteCubit = context.read<NoteCubit>();

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        // QUAN TRỌNG: Phải cung cấp NoteCubit cho màn hình Editor
        // để nó gọi hàm updateNote được.
        value: noteCubit,
        child: NoteEditorScreen(
          uid: uid,
          note: note, // Truyền Note cần sửa vào
          parentFolderId: parentFolderId ?? 'Root',
        ),
      ),
    ));
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New'),
        content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Name"),
            autofocus: true
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          // Add Note (Tạo nhanh note rỗng)
          ElevatedButton.icon(
            icon: const Icon(Icons.note_add),
            label: const Text('Note'),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<NoteCubit>().addNote(
                    uid, nameController.text, '', parentFolderId ?? 'Root', [], [], []
                );
                Navigator.of(ctx).pop();
              }
            },
          ),
          // Add Folder
          ElevatedButton.icon(
            icon: const Icon(Icons.folder),
            label: const Text('Folder'),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<FolderCubit>().createSubFolder(
                    uid, nameController.text, parentFolderId ?? 'Root'
                );
                Navigator.of(ctx).pop();
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
        title: Text(folderName),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () => _showCreateDialog(context),
              tooltip: 'Create'
          ),
        ],
      ),
      body: BlocBuilder<FolderCubit, FolderState>(
        builder: (context, state) {
          if (state is FolderLoading) return const Center(child: CircularProgressIndicator());
          if (state is FolderFailure) return Center(child: Text('Error: ${state.message}'));

          // Hứng State Grouped
          if (state is FolderGroupedLoaded) {
            // Lấy item từ Map theo ID
            final items = state.groupedData[parentFolderId] ?? [];

            if (items.isEmpty) return const Center(child: Text("Empty Folder"));

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                if (item is Folder) {
                  return ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(item.name ?? ""),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => _navigateToSubFolder(context, item),
                  );
                } else if (item is Note) {
                  return ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(item.title ?? ""),
                    subtitle: Text(
                      item.createdAt != null
                          ? "Created: ${item.createdAt.toString().split(' ')[0]}"
                          : "",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    // [ĐÃ SỬA] Gọi hàm mở Editor khi bấm vào Note
                    onTap: () => _openNoteEditor(context, item),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
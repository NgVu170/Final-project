import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:note_app_using_para/Data/Model/folder.dart';
import 'package:note_app_using_para/Data/Repository/folder_repository.dart';
import 'package:note_app_using_para/Data/Model/note.dart';
import 'package:note_app_using_para/Data/Repository/note_repository.dart';
import 'package:rxdart/rxdart.dart';


import '../../Core/Utils/firestore_helper.dart';

part 'folder_state.dart';

class FolderCubit extends Cubit<FolderState> {
  final FolderRepository _folderRepo;
  NoteRepository _noteRepo;
  StreamSubscription? _folderSub;

  FolderCubit(this._folderRepo, this._noteRepo) : super(FolderInitial());

  void fetchFolders(String userId) {
    emit(FolderLoading());
    _folderSub?.cancel();
    _folderSub = _folderRepo.getFolderStream(userId).listen((foldersData) {
      if (foldersData.isEmpty) {
        initSystemFolder(userId);
      }
      emit(FolderLoaded(foldersData));
    }, onError: (e) {
      emit(FolderFailure(e.toString()));
    });
  }

  void fetchSubFolders(String userId, String parentId) {
    emit(FolderLoading());
    _folderSub?.cancel();
    _folderSub = _folderRepo.getSubFoldersStream(userId, parentId).listen((folders) {
      emit(FolderLoaded(folders));
    }, onError: (e) {
      emit(FolderFailure(e.toString()));
    });
  }

  Future<void> initSystemFolder(String userId) async {
    try {
      await _folderRepo.ensureSystemFoldersExist(userId);
    } catch (e) {
      emit(FolderFailure("[ERROR] Init PARA folders: $e"));
    }
  }

  void initRealtimeData(String uid){
    emit(FolderLoading());
    _folderSub?.cancel(); // Đảm bảo hủy stream cũ

    print("--- [DEBUG] START LISTENING STREAM FOR UID: $uid ---");

    final combineStream = Rx.combineLatest2(
      _folderRepo.getFolderStream(uid),
      _noteRepo.getNoteStream(uid),
          (List<Folder> folders, List<Note> notes) {

        // 1. LOG XEM DATA TỪ FIREBASE CÓ VỀ KHÔNG?
        print("--- [DEBUG] DATA RECEIVED ---");
        print("Folders count: ${folders.length}");
        print("Notes count: ${notes.length}");
        if (notes.isNotEmpty) {
          print("First Note ParentID: '${notes.first.parentFolderId}'");
        }

        final Map<String?, List<dynamic>> tempMap = {};

        void addItem(String? parentId, dynamic item) {
          // [QUAN TRỌNG] Chuẩn hóa Key: Nếu null hoặc rỗng thì quy về 'Root' (hoặc null tùy logic bạn muốn)
          // Hãy thử log xem item này đang được nhét vào key nào
          print("Adding item to Key: '$parentId'");

          final key = parentId;
          if (!tempMap.containsKey(key)) {
            tempMap[key] = [];
          }
          tempMap[key]!.add(item);
        }

        // Gom nhóm Folder
        for (var f in folders) addItem(f.parentFolderId, f);

        // Gom nhóm Note
        for (var n in notes) addItem(n.parentFolderId, n);

        // 2. LOG XEM MAP SAU KHI GOM NHÓM RA SAO
        print("--- [DEBUG] MAP KEYS: ${tempMap.keys.toList()} ---");

        return tempMap;
      },
    );

    _folderSub = combineStream.listen(
            (groupedMap){
          print("--- [DEBUG] EMIT STATE: FolderGroupedLoaded ---");
          emit(FolderGroupedLoaded(groupedMap));
        },
        onError: (e){
          print("--- [DEBUG] ERROR: $e ---");
          emit(FolderFailure(e.toString()));
        }
    );
  }

  Future<void> createSubFolder(String userId, String folderName, String parentId) async {
    try {
      if (folderName.trim().isEmpty) {
        emit(FolderFailure("[ERROR] Folder must have a name"));
        return;
      }

      final newFolder = Folder(
        userId: userId,
        parentFolderId: parentId,
        name: folderName,
        createdAt: DateTime.now(),
        type: 'Custom',
      );
      await _folderRepo.addFolder(userId, newFolder);
      // FIX: The stream will update automatically. No need to call fetch again.
    } catch (e) {
      emit(FolderFailure("[ERROR] Create folder: ${e.toString()}"));
    }
  }

  Future<void> updateFolder(String userId, Folder folder) async {
    try {
      await _folderRepo.updateFolder(userId, folder);
    } catch (e) {
      emit(FolderFailure("[ERROR] Update folder: ${e.toString()}"));
    }
  }

  Future<void> deleteSubFolder(String userId, Folder folderSelected) async {
    try {
      final isNotEmpty = await _folderRepo.hasSubItems(userId, folderSelected.id!);
      if (isNotEmpty) {
        emit(FolderFailure("[ERROR] Folder ${folderSelected.name} is not empty"));
        return;
      }
      await _folderRepo.deleteFolder(userId, folderSelected.id!);
    } catch (e) {
      emit(FolderFailure("[ERROR] Delete folder ${folderSelected.name}: ${e.toString()}"));
    }
  }

  Future<void> moveFolder(String userId, Folder folder, String newParentId) async {
    final updatedFolder = folder.copyWith(parentFolderId: newParentId);
    await _folderRepo.updateFolder(userId, updatedFolder);
  }

  @override
  Future<void> close() {
    _folderSub?.cancel();
    return super.close();
  }
}
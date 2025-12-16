import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:note_app_using_para/Data/Model/note.dart';
import 'package:note_app_using_para/Data/Repository/note_repository.dart';

part 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  //region Attribute and constructor
  final NoteRepository _repo;
  StreamSubscription? _noteSub;
  NoteCubit(this._repo) : super(NoteInitial());
  //endregion
  //region Helper
  Future<List<String>> _uploadImgToFirebase(String userId, List<String> paths) async{
    List<String> downloadUrls = [];
    final storageRef = FirebaseStorage.instance.ref();
    for(var path in paths){
     File file = File(path);
     String fileName = "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
     final imgRef = storageRef.child("users/$userId/uploads/$fileName");
     try{
       await imgRef.putFile(file);
       String url = await imgRef.getDownloadURL();
       downloadUrls.add(url);
     } catch (e) {
       emit(NoteFailure("[ERROR] Uploading img: ${e.toString()}"));
     }
    }
    return downloadUrls;
  }

  List<String> _processTags(List<String>? tags) {
    if (tags == null) return [];
    return tags
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> _processLinks(List<String>? links) {
    if (links == null) return [];
    return links
        .map((e) => e.trim())
        .where((e) => Uri.tryParse(e)?.hasAbsolutePath ?? false)
        .toList();
  }
  //endregion
  //region Methods
  void fetchNotes(String userId){
    emit(NoteLoading()); //loading
    _noteSub?.cancel(); //delete the previous stream
    _noteSub = _repo.getNoteStream(userId).listen((notes){
      emit(NoteLoaded(notes));
    }, onError: (e){
      emit(NoteFailure(e.toString()));
    });
  }
  // --- ADD NOTE ---
  Future<void> addNote (String userId, String title, String content,
      List<String>? tags,
      List<String>? localImagePath,
      List<String>? urlLinks) async{
    try{
      emit(NoteLoading());
      List<String> cloudUrls = [];

      if (localImagePath != null && localImagePath.isNotEmpty) {
        // Upload và lấy link 'https://' về
        cloudUrls = await _uploadImgToFirebase(userId, localImagePath);
      }

      final cleanTags = _processTags(tags);
      final cleanLinks = _processLinks(urlLinks);

      final note = Note(
        userId: userId,
        title: title,
        content: content,
        createdAt: DateTime.now(),
        parentFolderId: 'Storage',
        isCompleted: false,
        tags: cleanTags,
        imageUrls: cloudUrls,
        urlLinks: cleanLinks,
      );
      await _repo.addNote(userId, note);
    } catch (e) {
      emit(NoteFailure("[ERROR] Create note: ${e.toString()}"));
    }
  }

  // --- DELETE NOTE ---
  Future<void> deleteNote(String userId, Note noteSelected) async{
    try{
      if (noteSelected.imageUrls != null) {
        for (String url in noteSelected.imageUrls! ) {
          try{
            await FirebaseStorage.instance.refFromURL(url).delete();
          } catch (e){
            emit(NoteFailure("[ERROR] Delete image $url note: ${e.toString()}"));
          }
        }
      }
      await _repo.deleteNote(userId, noteSelected.id!);
    } catch (e) {
      emit(NoteFailure("[ERROR] Delete note: ${e.toString()}"));
    }
  }

  // --- UPDATED NOTE ---
  Future<void> updateNote(String userId, Note note) async{
    try{
      await _repo.updateNote(userId, note);
    } catch (e) {
      emit(NoteFailure("[ERROR] Update note: ${e.toString()}"));
    }
  }

  // --- MOVE NOTE ---
  Future<void> moveNote (String userId, Note note, String newFolderId) async{
    try{
      final updatedNote = note.copyWith(parentFolderId: newFolderId);
      await _repo.updateNote(userId, updatedNote);
    } catch (e) {
      emit(NoteFailure("[ERROR] Move note: $e"));
    }
  }
  //endregion

  @override
  Future<void> close(){
    _noteSub?.cancel();
    return super.close();
  }
}
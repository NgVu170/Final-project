import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Core/Utils/firestore_helper.dart';
import '../Model/note.dart';

class NoteRepository {
  Stream<List<Note>> getNoteStream(String userId){
    return FirestoreHelper
        .noteRef(userId)
        .orderBy('dateCreated', descending: true)
        .snapshots()
        .map((snapshot){
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> addNote(String userId, Note newNote) async{
    try{
      await FirestoreHelper.noteRef(userId).add(newNote);
    } catch (e){
      throw Exception("[ERROR] Adding note: $e");
    }
  }

  Future<void> deleteNote(String userId, String noteId) async{
    try{
      await FirestoreHelper.noteRef(userId).doc(noteId).delete();
    } catch (e){
      throw Exception("[ERROR] Deleting note: $e");
    }
  }

  Future<void> updateNote(String userId, Note updatedNote) async {
    try {
      // FIX: Chỉ chặn nếu ID bị null hoặc rỗng
      if (updatedNote.id == null || updatedNote.id!.isEmpty) {
        throw Exception("Cannot update note without ID");
      }

      await FirestoreHelper.noteRef(userId)
          .doc(updatedNote.id)
          .set(updatedNote, SetOptions(merge: true));

      print("[REPO] Note updated: ${updatedNote.id}");
    } catch (e) {
      throw Exception("[ERROR] Updating note: $e");
    }
  }
}
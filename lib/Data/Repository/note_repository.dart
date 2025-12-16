import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Core/Utils/firestore_helper.dart';
import '../Model/note.dart';

class NoteRepository {
  Stream<List<Note>> getNoteStream(String userId){
    return FirestoreHelper
        .noteRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot){
          return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
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

  Future<void> updateNote(String userId, Note updatedNote) async{
    try{
      if (updatedNote.id!.isNotEmpty) return;
      await FirestoreHelper.noteRef(userId)
          .doc(updatedNote.id)
          .set(updatedNote, SetOptions(merge: true));
    } catch (e){
      throw Exception("[ERROR] Updating note: $e");
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Core/Utils/firestore_helper.dart';
import '../Model/folder.dart';

class FolderRepository {
  Stream<List<Folder>> getFolderStream(String userId){
    return FirestoreHelper
        .folderRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot){
          return snapshot.docs.map((doc) => Folder.fromFirestore(doc)).toList();
    });
  }

  Future<void> addFolder(String userId, Folder newFolder) async{
    try{
      await FirestoreHelper.folderRef(userId).add(newFolder);
    } catch (e){
      throw Exception("[ERROR] Adding note: $e");
    }
  }

  //Final step. In previous will find the child than delete it first
  Future<void> deleteFolder(String userId, String folderId) async{
    try{
      await FirestoreHelper.noteRef(userId).doc(folderId).delete();
    } catch (e){
      throw Exception("[ERROR] Deleting folder: $e");
    }
  }

  Future<void> updateNote(String userId, Folder updatedFolder) async{
    try{
      if (updatedFolder.id!.isNotEmpty) return;
      await FirestoreHelper.folderRef(userId)
          .doc(updatedFolder.id)
          .set(updatedFolder, SetOptions(merge: true));
    } catch (e){
      throw Exception("[ERROR] Updating note: $e");
    }
  }
}
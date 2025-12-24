import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Core/Utils/firestore_helper.dart';
import '../Model/folder.dart';

class FolderRepository {
  Stream<List<Folder>> getFolderStream(String userId){
    return FirestoreHelper
        .folderRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        // FIX: The .withConverter already returns Folder objects. We just need to get them.
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Folder>> getSubFoldersStream(String userId, String parentId){
    return FirestoreHelper.folderRef(userId)
        .where('parentFolderId', isEqualTo: parentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        // FIX: Apply the same correction here.
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<bool> hasSubItems(String userId, String folderId) async{
    final subFolderSnapshot = await FirestoreHelper.folderRef(userId)
        .where('parentFolderId', isEqualTo: folderId)
        .limit(1)
        .get();
    if (subFolderSnapshot.docs.isNotEmpty) return true;
    final noteSnapshot = await FirestoreHelper.noteRef(userId)
        .where('parentFolderId', isEqualTo: folderId)
        .limit(1)
        .get();
    return noteSnapshot.docs.isNotEmpty;
  }

  Future<void> addFolder(String userId, Folder newFolder) async{
    try{
      await FirestoreHelper.folderRef(userId).add(newFolder);
    } catch (e){
      throw Exception("[ERROR] Adding folder: $e");
    }
  }

  Future<void> deleteFolder(String userId, String folderId) async{
    try{
      await FirestoreHelper.folderRef(userId).doc(folderId).delete();
    } catch (e){
      throw Exception("[ERROR] Deleting folder: $e");
    }
  }

  Future<void> updateFolder(String userId, Folder updatedFolder) async{
    try{
      if (updatedFolder.id == null || updatedFolder.id!.isEmpty) return;
      await FirestoreHelper.folderRef(userId)
          .doc(updatedFolder.id)
          .set(updatedFolder, SetOptions(merge: true));
    } catch (e){
      throw Exception("[ERROR] Updating folder: $e");
    }
  }

  Future<bool> checkIfUserHasFolders(String userId) async {
    final snapshot = await FirestoreHelper.folderRef(userId).limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void>  ensureSystemFoldersExist(String userId) async {
    final hasData = await checkIfUserHasFolders(userId);
    if (hasData) return;

    final systemFolders = ['Projects', 'Areas', 'Resources', 'Archives'];
    final batch = FirebaseFirestore.instance.batch();
    for( var name in systemFolders){
      final docRef = FirestoreHelper.folderRef(userId).doc();
      final folder = Folder(
        userId: userId,
        name: name,
        createdAt: DateTime.now(),
        parentFolderId: 'Root',
        isSystem: true,
      );
      batch.set(docRef, folder);
    }
    await batch.commit();
  }
}
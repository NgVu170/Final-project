import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Data/Model/note.dart';
import '../../Data/Model/folder.dart';
import '../../Data/Model/user.dart';

class FirestoreHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  //Folder reference
  static CollectionReference<Folder> folderRef(String userId){
    return _db
      .collection('users')
      .doc(userId)
      .collection('folders')
      .withConverter<Folder>(
        fromFirestore: (snapshot, _) => Folder.fromFirestore(snapshot),
        toFirestore: (snapshot,_) => snapshot.toFireStore(),
      );
  }
  //Note reference
  static CollectionReference<Note> noteRef(String userId){
    return _db
    .collection('users')
    .doc(userId)
    .collection('notes')
    .withConverter<Note>(
      fromFirestore: (snapshot, _) => Note.fromFirestore(snapshot),
      toFirestore: (snapshot,_) => snapshot.toFirestore(),
    );
  }
  //User preference
  static CollectionReference<AppUser> userRef(){
    return _db
      .collection('users')
      .withConverter<AppUser>(
        fromFirestore: (snapshot, _) => AppUser.fromFirestore(snapshot),
        toFirestore: (snapshot,_) => snapshot.toJson(),
      );
  }
}
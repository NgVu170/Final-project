import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Core/Utils/firestore_helper.dart';
import '../Model/user.dart';

class AppUserRepository{
  Stream<AppUser?> getUserStream(String userId){
    return FirestoreHelper
        .userRef()
        .doc(userId)
        .snapshots()
        .map((snapshot) {
        if (!snapshot.exists) return null;
        return snapshot.data();
      }
    );
  }

  Future<void> createUser(AppUser newUser) async{
    try{
      await FirestoreHelper.userRef().doc(newUser.id).set(newUser);
    } catch (e){
      throw Exception("[ERROR] Adding user: $e");
    }
  }

  Future<void> updateUser(AppUser updatedUser) async{
    try{
      if(updatedUser.id.isEmpty) return;
      await FirestoreHelper.userRef()
          .doc(updatedUser.id)
          .set(updatedUser, SetOptions(merge: true));
    } catch (e){
      throw Exception("[ERROR] Updating user: $e");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await FirestoreHelper.userRef().doc(userId).delete();
    } catch (e) {
      throw Exception("[ERROR] Deleting user: $e");
    }
  }
}
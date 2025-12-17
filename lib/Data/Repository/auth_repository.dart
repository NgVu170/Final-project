import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_app_using_para/Data/Repository/appuser_repository.dart';
import '../Model/user.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final AppUserRepository _userRepo = AppUserRepository();

  Future<void> signUp({required String email,
    required String password,
    required String displayName,
    String? avatarUrl}) async {
    try{
      UserCredential cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      if (cred.user != null){
        final newUser = AppUser(
          id: cred.user!.uid,
          email: email,
          displayName: displayName,
          photoUrl: avatarUrl ?? null,
          joinedAt: DateTime.now(),
        );
        await _userRepo.createUser(newUser);
      }
    } catch (e){
      throw Exception("[ERROR] AppUser + AuthUser: $e");
    }
  }

  Future<void> signIn({
   required String email,
   required String password
  }) async{
    try{
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
    } on FirebaseAuthException catch (e){
      String message = '';
      if (e.code == 'user-not-found'){
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password'){
        message = 'Wrong password.';
      } else if (e.code == 'invalid-email'){
        message = 'Invalid email.';
      } else{
        message = 'Something went wrong.';
      }
      throw Exception("[ERROR] $message");
    } catch (e){
      throw Exception("[SYSTEM ERROR] AppUser + AuthUser: $e");
    }
  }

  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async{
    try{
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e){
      throw Exception("[ERROR] Reset password: $e");
    }
  }
}
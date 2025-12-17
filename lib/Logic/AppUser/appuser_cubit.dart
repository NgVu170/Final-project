import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../Data/Model/user.dart';
import '../../Data/Repository/appuser_repository.dart';

part 'appuser_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  final AppUserRepository _appUserRepo;
  StreamSubscription? _appUserSubscription;

  AppUserCubit(this._appUserRepo) : super(AppUserInitial());

  void subscribeUserProfile(String uid){
    emit(AppUserLoading());
    _appUserSubscription?.cancel();
    _appUserSubscription = _appUserRepo.getUserStream(uid).listen(
            (appUser){
          if(appUser != null){
            emit(AppUserLoaded(appUser));
          } else{
            emit(AppUserFailure("User not found"));
          }
        },
        onError: (e){
          emit(AppUserFailure("[SYSTEM] Fetch user: ${e.toString()}"));
        }
    );
  }

  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? photoUrl
  }) async {
    try{
      if (state is AppUserLoaded){

        final currentUser = (state as AppUserLoaded).user;
        String? finalPhotoUrl = currentUser.photoUrl;

        if (photoUrl != null && photoUrl.isNotEmpty) {
          if (!photoUrl.startsWith('http')) {
            finalPhotoUrl = await uploadImage(uid, photoUrl);
          }
        }

        final updatedUser = currentUser.copyWith(
          displayName: displayName ?? currentUser.displayName,
          photoUrl: finalPhotoUrl,
        );
        await _appUserRepo.updateUser(updatedUser);
      }
    } catch (e){
      print("Update lỗi: $e");
    }
  }

  Future<String> uploadImage(String uid, String imagePath) async{
    try{
      File file = File(imagePath);
      final ref = FirebaseStorage.instance.ref().child('users/$uid/profile.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Lỗi upload ảnh: $e");
    }
  }

  @override
  Future<void> close() {
    _appUserSubscription?.cancel();
    return super.close();
  }
}
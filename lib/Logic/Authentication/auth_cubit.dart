import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Data/Repository/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepo = AuthRepository();
  StreamSubscription? _authSubscription;
  AuthCubit() : super(AuthInitial()){
    _subscribeToAuthStream();
  }

  void _subscribeToAuthStream() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> logIn(String email, String password) async {
    try{
      await _authRepo.signIn(email: email, password: password);
    } catch (e) {
      emit(AuthFailure("[SYSTEM] Login: ${e.toString()}"));
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    try{
      emit(AuthLoading());
      _authRepo.signUp(email: email, password: password, displayName: displayName);
    } catch (e){
      emit(AuthFailure("[SYSTEM] Signup: ${e.toString()}"));
    }
  }

  Future<void> signOut() async {
    try{
      await _authRepo.signOut();
    } catch (e){
      emit(AuthFailure("[SYSTEM] Signout: ${e.toString()}"));
    }
  }

  Future<void> resetPassword(String email) async{
    try{
      emit(AuthLoading());
      _authRepo.resetPassword(email);
      emit(Unauthenticated());
    } catch (e){
      emit(AuthFailure("[SYSTEM] Reset password: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
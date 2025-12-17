part of 'appuser_cubit.dart';

abstract class AppUserState extends Equatable{
  const AppUserState();
  @override
  List<Object> get props => [];
}
class AppUserInitial extends AppUserState {}

class AppUserLoading extends AppUserState {}

class AppUserFailure extends AppUserState{
  final String message;
  const AppUserFailure(this.message);
  @override
  List<Object> get props => [message];
}
class AppUserLoaded extends AppUserState{
  final AppUser user;
  const AppUserLoaded(this.user);
  @override
  List<Object> get props => [user];
}

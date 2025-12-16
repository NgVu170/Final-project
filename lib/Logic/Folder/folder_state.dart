part of 'folder_cubit.dart';

abstract class FolderState extends Equatable {
  const FolderState();
  @override
  List<Object> get props => [];
}

class FolderInitial extends FolderState {}

class FolderLoading extends FolderState {}

class FolderSuccess extends FolderState {
  final String message;
  const FolderSuccess(this.message);
}

class FolderFailure extends FolderState{
  final String message;
  const FolderFailure(this.message);
}

class FolderLoaded extends FolderState {
  final List<Folder> folders;
  const FolderLoaded(this.folders);

  @override
  List<Object> get props => [folders];
}

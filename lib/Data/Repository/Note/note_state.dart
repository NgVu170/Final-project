part of 'note_cubit.dart';

abstract class NoteState extends Equatable{
  const NoteState();
  @override
  List<Object> get props => [];
}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteSuccess extends NoteState {
  final String message;
  const NoteSuccess(this.message);
}

class NoteFailure extends NoteState{
  final String message;
  const NoteFailure(this.message);
}

class NoteLoaded extends NoteState{
  final List<Note> notes;
  const NoteLoaded(this.notes);

  @override
  List<Object> get props => [notes];
}

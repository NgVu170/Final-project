import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

//Import Repo and Cubit for backend
import 'Data/Repository/auth_repository.dart';
import 'Data/Repository/appuser_repository.dart';
import 'Data/Repository/folder_repository.dart';
import 'Data/Repository/note_repository.dart';
import 'Logic/Authentication/auth_cubit.dart';
import 'Logic/AppUser/appuser_cubit.dart';
import 'Logic/Folder/folder_cubit.dart';
import 'Logic/Note/note_cubit.dart';
import 'Logic/Theme/theme_cubit.dart';

import 'firebase_options.dart';
//Import Presentation for UI
import 'Presentation/Screens/Authentication/login_screen.dart';
import 'Presentation/Screens/root_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NoteAppUsingPara());
}

class NoteAppUsingPara extends StatelessWidget{
  const NoteAppUsingPara({super.key});

  @override
  Widget build(BuildContext context){
    final authRepo = AuthRepository();
    final appUserRepo = AppUserRepository();
    final noteRepo = NoteRepository();
    final folderRepo = FolderRepository();

    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: authRepo),
          RepositoryProvider.value(value: appUserRepo),
          RepositoryProvider.value(value: noteRepo),
          RepositoryProvider.value(value: folderRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit()),
            BlocProvider(create: (_) => AuthCubit(authRepo,folderRepo)),
            BlocProvider(create: (_) => AppUserCubit(appUserRepo)),
            BlocProvider(create: (_) => FolderCubit(folderRepo)),
            BlocProvider(create: (_) => NoteCubit(noteRepo)),
          ],
          child: const AppContent(),
        )
    );
  }
}

class AppContent extends StatelessWidget{
  const AppContent({super.key});

  @override
  Widget build (BuildContext context){
    return BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'PARA note app',
              theme: themeState.themeData,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FlutterQuillLocalizations.delegate, 
              ],
              supportedLocales: FlutterQuillLocalizations.supportedLocales,

              home: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is Unauthenticated) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                builder: (context, authState) {
                  if (authState is Authenticated) {
                    return RootScreen(uid: authState.user.uid);
                  }
                  return const LoginScreen();
                },
              ),
          );
        }
    );
  }
}

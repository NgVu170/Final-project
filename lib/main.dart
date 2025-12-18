import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
//Import Repo and Cubit for backend
import 'Data/Repository/auth_repository.dart';
import 'Data/Repository/appuser_repository.dart';
import 'Data/Repository/note_repository.dart'; // Giả sử đã có
import 'Logic/Authentication/auth_cubit.dart';
import 'Logic/AppUser/appuser_cubit.dart';
import 'Logic/Theme/theme_cubit.dart';
import 'Presentation/Screens/AppUser/homeScreen.dart';
import 'firebase_options.dart';
//Import Presentation for UI
import 'Presentation/Screens/Authentication/loginScreen.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NoteAppUsingPara());
}

class NoteAppUsingPara extends StatelessWidget{
  const NoteAppUsingPara({super.key});

  @override
  Widget build(BuildContext context){
    final authRepo = AuthRepository();
    final appUserRepo = AppUserRepository();
    final noteRepo = NoteRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepo),
        RepositoryProvider.value(value: appUserRepo),
        RepositoryProvider.value(value: noteRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => AuthCubit(authRepo)),
          BlocProvider(create: (_) => AppUserCubit(appUserRepo)),
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
            home: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState){
                if (authState is Authenticated){
                  return RootScreen(uid: authState.user.uid);
                }
                if (authState is Unauthenticated) {
                  return const LoginScreen();
                }
                return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
                );
              },
            )
          );
        }
    );
  }
}
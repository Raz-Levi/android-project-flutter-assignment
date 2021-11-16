import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:hello_me/firebase_wrapper/auth_repository.dart';
import 'package:hello_me/firebase_wrapper/storage_repository.dart';
import 'package:hello_me/global/resources.dart';
import 'package:hello_me/pages/suggestions.dart';
import 'package:hello_me/global/constants.dart' as gc; // GlobalConst

// ================= App =================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthRepository>(
              create: (_) => AuthRepository.instance()),
          ChangeNotifierProxyProvider<AuthRepository, SavedSuggestionsStore>(
            create: (BuildContext context) => SavedSuggestionsStore.instance(Provider.of<AuthRepository>(context, listen: false)),
            update: (BuildContext context, AuthRepository auth, SavedSuggestionsStore? saved) => saved!..updates(auth),
          )
        ],
        child: MaterialApp(
          title: strAPP_TITLE,
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              backgroundColor: gc.primaryColor,
              foregroundColor: gc.secondaryColor,
            ),
          ),
          home: const Suggestions(),
        ));
  }
}

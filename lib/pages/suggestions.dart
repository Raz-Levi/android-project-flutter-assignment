// ================= Suggestions Screen =================
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';

import 'package:hello_me/firebase_wrapper/auth_repository.dart';
import 'package:hello_me/firebase_wrapper/storage_repository.dart';
import 'package:hello_me/pages/login.dart';
import 'package:hello_me/pages/saved_suggestions.dart';
import 'package:hello_me/widgets/welcome_widget.dart';
import 'package:hello_me/global/utils.dart';
import 'package:hello_me/global/resources.dart';
import 'package:hello_me/global/constants.dart' as gc; // GlobalConst

class Suggestions extends StatefulWidget {
  const Suggestions({Key? key}) : super(key: key);

  @override
  _Suggestions createState() => _Suggestions();
}

class _Suggestions extends State<Suggestions> {
  final _suggestions = <WordPair>[];

  Widget _buildRow(String pair, SavedSuggestionsStore _savedSuggestions) {
    if (_savedSuggestions.saved == null) {
      return Container();
    }
    final alreadySaved = _savedSuggestions.saved!.contains(pair);
    return ListTile(
      title: Text(
        pair,
        style: gc.biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? gc.favoriteIcon : gc.favoriteIconBorder,
        color: alreadySaved ? gc.primaryColor : null,
        semanticLabel: alreadySaved ? strREMOVED_FROM_SAVED : strSAVE,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _savedSuggestions.deletePair(pair);
          } else {
            _savedSuggestions.addPair(pair);
          }
        });
      },
    );
  }

  Widget _buildSuggestions(SavedSuggestionsStore savedSuggestions) {
    return ListView.builder(
        padding: const EdgeInsets.all(gc.suggestionsPadding),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return const Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(gc.generateMoreWords));
          }
          return _buildRow(_suggestions[index].asPascalCase.toString(), savedSuggestions);
        });
  }

  void _pushSaved(SavedSuggestionsStore savedSuggestions) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return SavedSuggestionsVM(savedSuggestions);
        },
      ),
    );
  }

  void _pushLogin(AuthRepository authRepository, SavedSuggestionsStore savedSuggestions) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return LoginVM(authRepository, savedSuggestions);
        },
      ),
    );
  }

  void _logoutApp(AuthRepository authRepository, SavedSuggestionsStore savedSuggestions) {
    authRepository.signOut();
    savedSuggestions.clearPairs(context);
    displaySnackBar(context, strLOGOUT_SUCCESSFULLY);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthRepository, SavedSuggestionsStore>(
      builder: (context, authRepository, savedSuggestions, child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text(strAPP_TITLE),
              actions: [
                IconButton(
                  icon: const Icon(gc.favoriteIcon),
                  onPressed: () {
                    _pushSaved(savedSuggestions);
                  },
                  tooltip: strSAVED_SUGGESTIONS,
                ),
                authRepository.status == Status.Authenticated
                    ? IconButton(
                  icon: const Icon(gc.authenticatedIcon),
                  onPressed: () {
                    setState(() => {_logoutApp(authRepository, savedSuggestions)});
                  },
                  tooltip: strLOGOUT,
                )
                    : IconButton(
                  icon: const Icon(gc.unauthenticatedIcon),
                  onPressed: () => _pushLogin(authRepository, savedSuggestions),
                  tooltip: strLOGIN,
                ),
              ],
            ),
            body:
            authRepository.status == Status.Authenticated
                ? WelcomeWidget(_buildSuggestions(savedSuggestions), authRepository)
                : _buildSuggestions(savedSuggestions));
      },
    );
  }
}

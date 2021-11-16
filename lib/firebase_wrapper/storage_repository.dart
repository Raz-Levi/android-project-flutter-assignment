// ================= Storage Repository =================
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hello_me/firebase_wrapper/auth_repository.dart';
import 'package:hello_me/global/constants.dart' as gc; // GlobalConst

Set<String> localSavedSuggestions = <String>{};

class SavedSuggestionsStore with ChangeNotifier {
  SavedSuggestionsStore.instance(AuthRepository authRepository) : _authRepository = authRepository, _saved = localSavedSuggestions;
  void updates(AuthRepository authRepository) {
    _authRepository = authRepository;
  }

  AuthRepository? _authRepository;
  Set<String> _saved = <String>{};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Set<String>? get saved => _saved;

  Future pushSaved() async {
    if (_authRepository != null && _authRepository!.user != null) {
      await _firestore.collection(gc.savedSuggestionsCollection).doc(_authRepository!.user!.email).set({
        gc.savedSuggestionsCollectionField: _saved.toList(),
      });
    }
  }

  Future pullSaved() async {
    if (_authRepository != null && _authRepository!.user != null) {
      await _firestore.collection(gc.savedSuggestionsCollection).doc(_authRepository!.user!.email).get().then((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          _saved.addAll(snapshot.data()![gc.savedSuggestionsCollectionField].cast<String>());
          notifyListeners();
        }
      });
    }
  }

  void addPair(String pair) {
    _saved.add(pair);
    localSavedSuggestions.add(pair);
    if (_authRepository != null && _authRepository!.status == Status.Authenticated) {
      pushSaved();
    }
    notifyListeners();
  }

  void deletePair(String pair) {
    _saved.remove(pair);
    localSavedSuggestions.remove(pair);
    if (_authRepository != null && _authRepository!.status == Status.Authenticated) {
      pushSaved();
    }
    notifyListeners();
  }

  void clearPairs(context) {
    _saved = <String>{};
    localSavedSuggestions = <String>{};
    notifyListeners();
  }
}

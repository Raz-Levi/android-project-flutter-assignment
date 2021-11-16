// ================= Auth Repository =================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:io';

import 'package:hello_me/global/constants.dart' as gc; // GlobalConst

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthRepository with ChangeNotifier {
  final FirebaseAuth _auth;
  User? _user;
  Status _status = Status.Uninitialized;

  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: gc.storageBucketPath);
  String? _avatarUrl;

  AuthRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;

  User? get user => _user;

  bool get isAuthenticated => status == Status.Authenticated;

  String? get avatarUrl => _avatarUrl;

  Future<void> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await signIn(email, password);
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _status = Status.Authenticated;
      _avatarUrl = await getAvatarUrl();
      notifyListeners();
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    _user = null;
    _avatarUrl = null;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  void uploadAvatar(XFile? avatarImage) async {
    if (avatarImage != null && _user != null) {
      Reference storageReference = _storage.ref().child(gc.avatarsCollection + '/' +_user!.email.toString());
      UploadTask uploadedAvatar = storageReference.putFile(File(avatarImage.path));
      await uploadedAvatar;
      _avatarUrl = await getAvatarUrl();
      notifyListeners();
    }
  }

  Future<String?> getAvatarUrl() async {
    try {
      Reference storageReference = _storage.ref().child(gc.avatarsCollection + '/' +_user!.email.toString());
      return await storageReference.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }
}

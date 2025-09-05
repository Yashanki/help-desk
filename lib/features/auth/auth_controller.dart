import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../users/user_repo.dart';
import '../users/app_user.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (_) => FirebaseAuth.instance,
);
final userRepoProvider = Provider<UserRepo>((_) => UserRepo());

// raw Firebase user
final firebaseUserStreamProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// app user joined with /users/{uid}
final appUserStreamProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final repo = ref.watch(userRepoProvider);
  return auth.authStateChanges().asyncExpand((u) {
    if (u == null) return Stream<AppUser?>.value(null);
    return repo.watchUser(u.uid);
  });
});

class AuthController {
  AuthController(this._auth);
  final FirebaseAuth _auth;

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.watch(firebaseAuthProvider));
});

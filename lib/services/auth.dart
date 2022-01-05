import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopper/models/users.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Users _usersFromFirebaseUser(User user) {
    return user != null ? Users(uid: user.uid) : null;
  }

  //auth change user stream
  Stream<Users> get userAuthChangeStream {
    return _auth.authStateChanges().map(_usersFromFirebaseUser);
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _usersFromFirebaseUser(user);
    } catch (e) {
      print("sign in error $e");
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User firebaseUser = result.user;
      return _usersFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e);
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
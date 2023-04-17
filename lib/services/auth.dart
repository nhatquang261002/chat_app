import 'package:chatapp_firebase/references/references.dart';
import 'package:chatapp_firebase/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseAuth instance = FirebaseAuth.instance;

  // login
  Future loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  // register
  Future registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await DatabaseService(uid: user.user?.uid).saveUserData(fullName, email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  // logout
  Future logOut() async {
    try {
      await References.saveUserLoggedInStatus(false);
      await References.saveUserEmailSF("");
      await References.saveUserNameSF("");
      await instance.signOut();
    } catch (e) {
      return null;
    }
  }
}

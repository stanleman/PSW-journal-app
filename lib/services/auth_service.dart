import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:psw_journal_app/pages/home/home.dart';
import 'package:psw_journal_app/pages/login/login.dart';
import 'package:psw_journal_app/pages/root.dart';
import 'package:toast/toast.dart';

class AuthService {
  User? loggedInUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => RootPage(),
          ));
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == "weak password") {
        message = 'The password is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email already in use';
      }
      print(message);
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => RootPage(),
          ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    // await Future.delayed(const Duration(seconds: 1));
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (BuildContext context) => Login()));
  }
}

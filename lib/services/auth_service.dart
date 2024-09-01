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

  Future<String> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } on FirebaseAuthException catch (e) {
      String message = 'Error signing up!';
      print(e.code);
      if (e.code == 'email-already-in-use') {
        message = 'Email already in use!';
      } else if (e.code == "weak-password") {
        message = 'The password is too weak!';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email.';
      }
      return message;
    }
  }

  Future<String> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'success';
      // await Future.delayed(const Duration(seconds: 1));
      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (BuildContext context) => RootPage(),
      //     ));
    } on FirebaseAuthException catch (e) {
      String message = 'Error signing in!';
      if (e.code == 'invalid-credential') {
        message = 'Invalid credentials provided.';
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
        print('Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email.';
        print('Invalid email.');
      }
      return message;
    }
  }

  Future<void> signout({required BuildContext context}) async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      print("error occured!");
    }
    // await Future.delayed(const Duration(seconds: 1));
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (BuildContext context) => Login()));
  }
}

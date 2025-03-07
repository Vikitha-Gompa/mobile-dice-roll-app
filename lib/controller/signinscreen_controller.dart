// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson6/controller/auth_controller.dart';
import 'package:lesson6/view/sigin_screen.dart';

class SignInScreenController {
  SignInState state;
  SignInScreenController(this.state);

  Future<void> signIn() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    if (!currentState.validate()) return;
    currentState.save();

    try {
      await firebaseSignIn(
        email: state.model.email!,
        password: state.model.password!,
      );
      // authStateChanged() => stream
    } on FirebaseAuthException catch (e) {
      var error = 'Sign in error! Reason ${e.code} ${e.message}';
      print('======== $error');
    } catch (e) {
      print('================= sign in error: $e');
    }
  }
}

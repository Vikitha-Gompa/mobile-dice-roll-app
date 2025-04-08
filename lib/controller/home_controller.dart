// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:lesson6/controller/auth_controller.dart';
import 'package:lesson6/model/home_model.dart';
import 'package:lesson6/view/home_screen.dart';
import 'package:lesson6/view/game_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeController {
  late HomeState state;
  dynamic screenState; // can be HomeState or GameScreenState

  HomeController(this.state) {
    screenState = state;
  }

  HomeController.fromGameScreen(this.screenState); // constructor for GameScreen

  // Navigate to GameRoom
  void onPressedEnterGameRoom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GameScreen(),
      ),
    );
  }

  void onPressedNewGame() {
    screenState.callSetState(() {
      screenState.model.newGame();
      screenState.model.progressMessage = '';

      screenState.model.radioEnabled = true;
      screenState.forceShowKey = false;
    });
  }

  void onPressedPlay() async {
    screenState.callSetState(() {
      screenState.model.gameState = GameState.PLAYING;
      screenState.model.getGameResult();
      int key = screenState.model.key;

      screenState.forceShowKey = true;

      String oddEvenResult = '';
      String rangeResult = '';

      // Odd/Even result message
      if (screenState.model.betOnOddEven > 0) {
        bool isKeyEven = key % 2 == 0;
        bool betCorrect = isKeyEven == screenState.model.even;
        String label = screenState.model.even ? 'Even' : 'Odd';
        oddEvenResult = betCorrect
            ? 'You won on $label: \$${screenState.model.betOnOddEven * 2} '
            : 'You lost on $label: \$${screenState.model.betOnOddEven} ';
      } else {
        oddEvenResult = 'No Bet Placed on Odd/Even';
      }

      // Range result message
      if (screenState.model.betOnRange > 0) {
        bool betCorrect = false;
        switch (screenState.model.range) {
          case '1-2':
            betCorrect = key >= 1 && key <= 2;
            break;
          case '3-4':
            betCorrect = key >= 3 && key <= 4;
            break;
          case '5-6':
            betCorrect = key >= 5 && key <= 6;
            break;
        }
        rangeResult = betCorrect
            ? 'You won on range ${screenState.model.range}: \$${screenState.model.betOnRange * 3}'
            : 'You lost on range ${screenState.model.range}: \$${screenState.model.betOnRange}';
      } else {
        rangeResult = ' No Bet Placed on Range';
      }

      screenState.model.radioEnabled = false;
      screenState.model.progressMessage = [oddEvenResult, rangeResult]
          .where((msg) => msg.isNotEmpty)
          .join('\n');

      // screenState.model.progressMessage = winAmount > 0
      //     ? 'You won \$$winAmount!'
      //     : 'You lost \${-winAmount.abs()}';
      screenState.model.gameState = GameState.DONE;
    });
    // Save data to Firestore after the game is played
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      await saveToFirestore(userEmail);
    } else {
      // Handle case where email is null (e.g., show error or fallback)
      print('User email is null');
    }
  }

  // Add this function to save data to Firestore
  Future<void> saveToFirestore(String email) async {
    try {
      // Get the Firestore collection reference
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get the Firestore object from the model
      Map<String, dynamic> data = screenState.model.toFirestoreObject(email);

      // Add or update the game data in Firestore
      await firestore
          .collection('diceroll_game')
          .add(data); // 'games' is the Firestore collection name

      print('Game data saved successfully');
    } catch (e) {
      print('Error saving data to Firestore: $e');
      // Handle any errors here, e.g., showing a UI error message
    }
  }

  void onToggleShowKey(bool value) {
    screenState.callSetState(() {
      screenState.model.showKey = value;
    });
  }

  void onSelectOddEven(bool evenSelected) {
    screenState.callSetState(() {
      screenState.model.even = evenSelected;
    });
  }

  void onSetOddEvenBet(int amount) {
    screenState.callSetState(() {
      screenState.model.betOnOddEven = amount;
    });
  }

  void onSelectRange(String selectedRange) {
    screenState.callSetState(() {
      screenState.model.range = selectedRange;
    });
  }

  void onSetRangeBet(int amount) {
    screenState.callSetState(() {
      screenState.model.betOnRange = amount;
    });
  }

  bool isPlayEnabled() {
    return screenState.model.gameState == GameState.INIT &&
        (screenState.model.betOnOddEven > 0 ||
            screenState.model.betOnRange > 0);
  }

  bool isNewGameEnabled() {
    return screenState.model.gameState != GameState.INIT;
  }

  Future<void> signOut() async {
    await firebaseSignOut();
  }
}

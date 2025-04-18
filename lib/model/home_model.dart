// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';

enum GameState { INIT, PLAYING, DONE }

class HomeModel {
  User user;
  HomeModel(this.user);
}

class GameModel {
  GameState gameState = GameState.INIT;
  String progressMessage = 'Choose Bet(s) and press [PLAY]';
  int betOnOddEven = 0;
  int betOnRange = 0;
  int balance = 100;
  bool even = false;
  String range = "1-2";
  int key = 0;
  bool showKey = false;
  bool radioEnabled = true;

  GameModel() {
    generateKey();
  }

  // void generateKey() {
  //   key = Random().nextInt(6) + 1;
  // }
  //int key = 1;

  void generateKey() {
    int newKey;
    do {
      newKey = Random().nextInt(6) + 1;
    } while (newKey == key); // Repeat if same as current key
    key = newKey;
  }

  int getGameResult() {
    final total = getEvenOddAmount() + getRangeAmount();
    balance += total;
    return total;
  }

  int getEvenOddAmount() {
    if (betOnOddEven == 0) return 0;
    if (even && key % 2 == 0) return betOnOddEven * 2;
    if (!even && key % 2 == 1) return betOnOddEven * 2;
    return betOnOddEven * -1;
  }

  int getRangeAmount() {
    if (betOnRange == 0) return 0;
    if (range == "1-2" && key >= 1 && key <= 2) return betOnRange * 3;
    if (range == "3-4" && key >= 3 && key <= 4) return betOnRange * 3;
    if (range == "5-6" && key >= 5 && key <= 6) return betOnRange * 3;
    return betOnRange * -1;
  }

  void newGame() {
    gameState = GameState.INIT;
    progressMessage = 'Choose Bet(s) and press [PLAY]';
    betOnOddEven = 0;
    betOnRange = 0;
    even = false;
    range = "1-2";
    generateKey();
  }

  void reset() {
    newGame();
    balance = 100;
    gameState = GameState.INIT;
  }

  Map<String, dynamic> toFirestoreObject(String email) {
    return {
      'balance': balance,
      'bet': betOnOddEven + betOnRange,
      'email': email,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'win': getEvenOddAmount() + getRangeAmount(),
    };
  }
}

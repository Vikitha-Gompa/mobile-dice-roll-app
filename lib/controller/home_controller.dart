import 'package:flutter/material.dart';
import 'package:lesson6/model/home_model.dart';
import 'package:lesson6/view/home_screen.dart';
import 'package:lesson6/view/game_screen.dart';

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

  void signOut() async {
    // Add your sign out logic
  }

  void onPressedNewGame() {
    screenState.callSetState(() {
      screenState.model.newGame();
      screenState.model.progressMessage = '';

      screenState.model.radioEnabled = true;
      screenState.forceShowKey = false;
    });
  }

  void onPressedPlay() {
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
}

import 'package:flutter/material.dart';
import 'package:lesson6/controller/home_controller.dart';
import 'package:lesson6/model/home_model.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late HomeController con;
  late GameModel model;
  bool forceShowKey = false;

  @override
  void initState() {
    super.initState();
    model = GameModel();
    con = HomeController.fromGameScreen(this);
  }

  void callSetState(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game Room")),
      body: GameBodyView(model: model, con: con),
    );
  }
}

class GameBodyView extends StatelessWidget {
  final GameModel model;
  final HomeController con;

  const GameBodyView({super.key, required this.model, required this.con});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Balance: \$${model.balance}'),
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 100,
            backgroundColor: Colors.blue,
            child: model.gameState == GameState.DONE
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        model.showKey || con.screenState.forceShowKey
                            ? '${model.key}' // Show key if showKey is true
                            : '?',
                        style: const TextStyle(fontSize: 20, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        model.progressMessage.isNotEmpty
                            ? model
                                .progressMessage // Show progress message when game is done
                            : 'Choose Bet(s) and press [PLAY]',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.yellow),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Text(
                    //model.gameState == GameState.INIT ? '?' : '',
                    model.showKey || con.screenState.forceShowKey
                        ? '${model.key}' // Show key if showKey is true
                        : '?',
                    style: const TextStyle(fontSize: 20, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Show Key:'),
              Switch(
                value: model.showKey,
                onChanged: con.onToggleShowKey,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Bet on even/odd: 2x winnings'),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: model.even,
                    onChanged: model.radioEnabled
                        ? (bool? value) => con.onSelectOddEven(value!)
                        : null,
                  ),
                  const Text('Odd'),
                  Radio<bool>(
                    value: true,
                    groupValue: model.even,
                    onChanged: model.radioEnabled
                        ? (bool? value) => con.onSelectOddEven(value!)
                        : null,
                  ),
                  const Text('Even'),
                ],
              ),
              const SizedBox(
                  height: 5), // Space between radio buttons and dropdown
              DropdownButton<int>(
                value: model.betOnOddEven == 0
                    ? null
                    : model
                        .betOnOddEven, // Default to null when no bet is selected
                hint: const Text('Select Bet on Even/Odd'),
                disabledHint: Text(
                  model.betOnOddEven == 0
                      ? 'Select Bet on Even/Odd'
                      : '\$${model.betOnOddEven}',
                ),

                items: [
                  null, // Represent the "Select Bet" option with null
                  10, 20, 30,
                ].map((amount) {
                  return DropdownMenuItem(
                    value: amount,
                    child: Text(
                      amount == null
                          ? 'Select Bet on Even/Odd'
                          : '\$$amount', // Display "Select Bet" for null

                      // Colors.blue, // Blue color for selected items
                    ),
                  );
                }).toList(),
                onChanged: model.radioEnabled
                    ? (amount) {
                        if (amount != null) {
                          con.onSetOddEvenBet(
                              amount); // Only update if amount is not null
                        } else {
                          con.onSetOddEvenBet(
                              0); // Reset bet when "Select Bet" is chosen
                        }
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Bet on range: 3x winnings'),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: '1-2',
                    groupValue: model.range,
                    onChanged: model.radioEnabled
                        ? (String? value) => con.onSelectRange(value!)
                        : null,
                  ),
                  const Text('1-2'),
                  Radio<String>(
                    value: '3-4',
                    groupValue: model.range,
                    onChanged: model.radioEnabled
                        ? (String? value) => con.onSelectRange(value!)
                        : null,
                  ),
                  const Text('3-4'),
                  Radio<String>(
                    value: '5-6',
                    groupValue: model.range,
                    onChanged: model.radioEnabled
                        ? (String? value) => con.onSelectRange(value!)
                        : null,
                  ),
                  const Text('5-6'),
                ],
              ),
              const SizedBox(
                  height: 5), // Space between radio buttons and dropdown
              DropdownButton<int>(
                value: model.betOnRange == 0
                    ? null
                    : model
                        .betOnRange, // Default to null when no bet is selected
                hint: const Text('Select Bet on Range'),
                disabledHint: Text(
                  model.betOnRange == 0
                      ? 'Select Bet on Range'
                      : '\$${model.betOnRange}',
                ),
                items: [
                  null, // Represent the "Select Bet" option with null
                  10, 20, 30,
                ].map((amount) {
                  return DropdownMenuItem(
                    value: amount,
                    child: Text(amount == null
                        ? 'Select Bet on Range'
                        : '\$$amount'), // Display "Select Bet" for null
                  );
                }).toList(),
                onChanged: model.radioEnabled
                    ? (amount) {
                        if (amount != null) {
                          con.onSetRangeBet(
                              amount); // Only update if amount is not null
                        } else {
                          con.onSetRangeBet(
                              0); // Reset bet when "Select Bet" is chosen
                        }
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(model.progressMessage),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: con.isPlayEnabled() ? con.onPressedPlay : null,
                child: const Text('Play'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: con.isNewGameEnabled() ? con.onPressedNewGame : null,
                child: const Text('New Game'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

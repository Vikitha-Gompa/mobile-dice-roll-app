import 'package:flutter/material.dart';
import 'package:lesson6/controller/auth_controller.dart';
import 'package:lesson6/controller/home_controller.dart';
import 'package:lesson6/model/home_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<HomeScreen> {
  late HomeController con;
  late GameModel model;
  late HomeModel modal;
  bool isInGameRoom = false;
  bool forceShowKey = false;

  @override
  void initState() {
    super.initState();
    model = GameModel();
    model.betOnOddEven = 0;
    model.betOnRange = 0;
    con = HomeController(this);
    modal = HomeModel(currentUser!);
  }

  void callSetState(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: true, // Don't show default back button
        actions: isInGameRoom
            ? [
                IconButton(
                  icon: const Icon(Icons.close), // or Icons.arrow_back
                  onPressed: () {
                    con.onBackPressed(context);
                  },
                ),
              ]
            : [],
      ),
      body: isInGameRoom ? gameRoomView(context) : homeBodyView(context),
      drawer: drawerView(context),
      // drawer: isInGameRoom ? null : drawerView(context),
    );
  }

  Widget homeBodyView(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              modal.user.email!,
              style: const TextStyle(fontSize: 30, color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              'Welcome to Dice Game!',
              style: TextStyle(fontSize: 30, color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                callSetState(() {
                  isInGameRoom = true;
                });
              },
              child: const Text('Enter Game Room'),
            ),
          ],
        ),
      ),
    );
  }

  Widget gameRoomView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Balance: \$${model.balance}'
            ' '
            '${(model.showKey) ? ' (key: ${model.key})' : ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 6,
              ),
            ),
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.blue,
              child: model.gameState == GameState.DONE
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          model.showKey || con.screenState.forceShowKey
                              ? '${model.key}'
                              : '?',
                          style:
                              const TextStyle(fontSize: 50, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 3),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: (model.progressMessage.isNotEmpty
                                  ? model.progressMessage.split('\n')
                                  : ['Choose Bet(s) and press [PLAY]'])
                              .map((line) => Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.yellow, width: 2),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      line,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        )
                      ],
                    )
                  : Text(
                      model.gameState == GameState.INIT ? '?' : '',
                      style: const TextStyle(fontSize: 80, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
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
          const Text(
            'Bet on even/odd: 2x winnings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
              const SizedBox(height: 5),
              Container(
                color: const Color.fromARGB(255, 139, 201, 230),
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: DropdownButton<int>(
                  value: model.betOnOddEven == 0 ? null : model.betOnOddEven,
                  hint: const Text('Select Bet on Even/Odd'),
                  disabledHint: Text(
                    model.betOnOddEven == 0
                        ? 'Select Bet on Even/Odd'
                        : '\$${model.betOnOddEven}',
                  ),
                  items: [null, 10, 20, 30].map((amount) {
                    return DropdownMenuItem(
                      value: amount,
                      child: Text(
                        amount == null ? 'Select Bet on Even/Odd' : '\$$amount',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: model.radioEnabled
                      ? (amount) => con.onSetOddEvenBet(amount ?? 0)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Bet on range: 3x winnings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
              const SizedBox(height: 5),
              Container(
                color: const Color.fromARGB(255, 139, 201, 230),
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: DropdownButton<int>(
                  value: model.betOnRange == 0 ? null : model.betOnRange,
                  hint: const Text('Select Bet on Range'),
                  disabledHint: Text(
                    model.betOnRange == 0
                        ? 'Select Bet on Range'
                        : '\$${model.betOnRange}',
                  ),
                  items: [null, 10, 20, 30].map((amount) {
                    return DropdownMenuItem(
                      value: amount,
                      child: Text(
                        amount == null ? 'Select Bet on Range' : '\$$amount',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: model.radioEnabled
                      ? (amount) => con.onSetRangeBet(amount ?? 0)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: con.isPlayEnabled() ? con.onPressedPlay : null,
                child: const Text('Play'),
              ),
              const SizedBox(width: 15),
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

  Widget drawerView(BuildContext context) {
    // print('drawerView called!');

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('No Profile'),
            accountEmail: Text(modal.user.email!),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: con.signOut,
          ),
        ],
      ),
    );
  }
}

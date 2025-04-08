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

  @override
  void initState() {
    super.initState();
    model = GameModel();
    model.betOnOddEven = 0; // Default to a valid value
    model.betOnRange = 0; // Default to a valid value
    con = HomeController(this);
    modal = HomeModel(currentUser!);
  }

  void callSetState(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: bodyView(context),
      drawer: drawerView(context),
    );
  }

  Widget bodyView(BuildContext context) {
    return PopScope(
      canPop: false, // disable system back button
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              modal.user.email!,
              style: const TextStyle(fontSize: 30, color: Colors.black),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Welcome to Dice Game!',
              style: const TextStyle(fontSize: 30, color: Colors.black),
            ),
            SizedBox(height: 20), // Adds spacing
            ElevatedButton(
              onPressed: () {
                con.onPressedEnterGameRoom(context);
              },
              child: Text('Enter Game Room'),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawerView(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('No Profile'),
            accountEmail: const Text('user@example.com'),
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

import 'package:flutter/material.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/crud/risk_service.dart';
import 'package:my_app/services/crud/user_service.dart';

import '../constants/routes.dart';
import '../enums/menu_actions.dart';
import '../utilities/show_logout_dialog.dart';

class RiskPage extends StatefulWidget {
  const RiskPage({super.key});

  @override
  State<RiskPage> createState() => _RiskPageState();
}

class _RiskPageState extends State<RiskPage> {
  late final RiskService _riskService;
  late final UserService _userService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

//Opening the DB to see the content in the view

  @override
  void initState() {
    _riskService = RiskService();
    _userService = UserService();
  }

//Closing the DB in the view
  @override
  void dispose() {
    _riskService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  if (shouldLogOut) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                )
              ];
            },
          )
        ],
        title: const Text('Risk Page'),
      ),
      body: FutureBuilder(
        future: _userService.getUserOrCreate(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Text('Waiting the see all the risks!..');
                  default:
                    return const CircularProgressIndicator();
                }
              });
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

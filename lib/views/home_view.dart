import 'package:flutter/material.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/enums/menu_action.dart';
import 'package:my_app/extensions/buildcontext/loc.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/auth/bloc/auth_bloc.dart';
import 'package:my_app/services/auth/bloc/auth_event.dart';
import 'package:my_app/services/cloud/cloud_risk.dart';
import 'package:my_app/services/cloud/firebase_cloud_storage.dart';
import 'package:my_app/utilities/dialogs/logout_dialog.dart';
import 'package:my_app/views/Risks/risks_view.dart';
import 'package:my_app/views/risks/risks_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final FirebaseCloudStorage _HomeService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _HomeService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safer')),
      body: const Center(
        child: Text('HOME'),
      ),
      drawer: const NavigationDrawer(),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
          child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeader(context),
              buildMenuIrems(context),
            ]),
      ));

  Widget buildHeader(BuildContext context) => Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
      );

  Widget buildMenuIrems(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          runSpacing: 16, //Vertical Spacing
          children: [
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('My profile'),
              onTap: (() {}),
            ),
            ListTile(
              leading: const Icon(Icons.dangerous_outlined),
              title: const Text('Risk'),
              onTap: (() => Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => const risksView())))),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Locations'),
              onTap: (() {}),
            ),
            ListTile(
              leading: const Icon(Icons.work_history_outlined),
              title: const Text('Works'),
              onTap: (() {}),
            ),
            ListTile(
              leading: const Icon(Icons.person_outlined),
              title: const Text('Job Profiles'),
              onTap: (() {}),
            ),
            ListTile(
              leading: const Icon(Icons.construction_outlined),
              title: const Text('Auth'),
              onTap: (() {}),
            ),
          ],
        ),
      );
}

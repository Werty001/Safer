import 'package:flutter/material.dart';
import 'package:my_app/enums/menu_action.dart';
import 'package:my_app/extensions/buildcontext/loc.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/auth/bloc/auth_bloc.dart';
import 'package:my_app/services/auth/bloc/auth_event.dart';
import 'package:my_app/services/cloud/firebase_cloud_risk_storage.dart';
import 'package:my_app/utilities/dialogs/logout_dialog.dart';
import 'package:my_app/views/Jobs_Profile/job_profile_view_silver.dart';
import 'package:my_app/views/Jobs_Profile/jobs_profile_view.dart';
import 'package:my_app/views/Locations/job_profile_view1.dart';
import 'package:my_app/views/Risks/risks_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:my_app/views/user_view.dart';
import 'package:my_app/views/weather/city_view.dart';
import 'package:my_app/views/weather/loading_view.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final FirebaseCloudRiskStorage _HomeService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _HomeService = FirebaseCloudRiskStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safer'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  }
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(context.loc.logout_button),
                ),
              ];
            },
          )
        ],
      ),
      body: Column(
        children: [Text('HOME')],
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

  Widget buildHeader(BuildContext context) => Material(
      color: Colors.orange.shade700,
      child: InkWell(
        onTap: () {
          //Navigate to User Description View
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const UserView(),
          ));
        },
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: 24,
          ),
          child: Column(
            children: const [
              CircleAvatar(
                radius: 52,
                backgroundColor: Colors.grey,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'User name',
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
              Text(
                'user@mail.com',
                style: TextStyle(fontSize: 22, color: Colors.white),
              )
            ],
          ),
        ),
      ));

  Widget buildMenuIrems(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          runSpacing: 16, //Vertical Spacing
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard_customize_outlined),
              title: const Text('Dashboards'),
              onTap: (() {}),
            ),
            ListTile(
              leading: const Icon(Icons.dangerous_outlined),
              title: const Text('Risk'),
              onTap: (() => Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => const RisksView())))),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Locations'),
              onTap: (() => Navigator.of(context).push(
                  MaterialPageRoute(builder: ((context) => LocationView())))),
            ),
            ListTile(
              leading: const Icon(Icons.work_history_outlined),
              title: const Text('Current Works'),
              onTap: (() => Navigator.of(context).push(
                  MaterialPageRoute(builder: ((context) => RisksView())))),
            ),
            ListTile(
              leading: const Icon(Icons.person_outlined),
              title: const Text('Job Profiles'),
              onTap: (() => Navigator.of(context)
                  .push(MaterialPageRoute(builder: ((context) => JobsView())))),
            ),
            ListTile(
              leading: const Icon(Icons.construction_outlined),
              title: const Text('Auth'),
              onTap: (() => Navigator.of(context).push(
                  MaterialPageRoute(builder: ((context) => CityScreen())))),
            ),
            ListTile(
              leading: const Icon(Icons.sunny_snowing),
              title: const Text('Weather'),
              onTap: (() => Navigator.of(context).push(
                  MaterialPageRoute(builder: ((context) => LoadingScreen())))),
            ),
          ],
        ),
      );
}

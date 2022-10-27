import 'package:flutter/material.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/cloud/cloud_risk.dart';
import 'package:my_app/services/cloud/firebase_cloud_risk_storage.dart';

import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:my_app/views/Risks/risks_list_view.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class CurrentWorksView extends StatefulWidget {
  const CurrentWorksView({Key? key}) : super(key: key);

  @override
  _CurrentWorksViewState createState() => _CurrentWorksViewState();
}

class _CurrentWorksViewState extends State<CurrentWorksView> {
  late final FirebaseCloudRiskStorage _RisksService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _RisksService = FirebaseCloudRiskStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currents Works'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateriskRoute);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _RisksService.allrisks(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allRisks = snapshot.data as Iterable<CloudRisk>;
                return RisksListView(
                  risks: allRisks,
                  onDeleterisk: (Risk) async {
                    await _RisksService.deleterisk(documentId: Risk.documentId);
                  },
                  onTap: (Risk) {
                    Navigator.of(context).pushNamed(
                      createOrUpdateriskRoute,
                      arguments: Risk,
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/extensions/buildcontext/loc.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/cloud/cloud_risk.dart';
import 'package:my_app/services/cloud/firebase_cloud_risk_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:my_app/views/risks/risks_list_view.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class RisksView extends StatefulWidget {
  const RisksView({Key? key}) : super(key: key);

  @override
  _RisksViewState createState() => _RisksViewState();
}

class _RisksViewState extends State<RisksView> {
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
        title: StreamBuilder(
          stream: _RisksService.allrisks(ownerUserId: userId).getLength,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              final RiskCount = snapshot.data ?? 0;
              final text = context.loc.risks_title(RiskCount);
              return Text(text);
            } else {
              return const Text('');
            }
          },
        ),
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

import 'package:flutter/material.dart';
import 'package:my_app/extensions/buildcontext/loc.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/utilities/dialogs/cannot_share_empty_risk_dialog.dart';
import 'package:my_app/utilities/generics/get_arguments.dart';
import 'package:my_app/services/cloud/cloud_risk.dart';
import 'package:my_app/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateriskView extends StatefulWidget {
  const CreateUpdateriskView({Key? key}) : super(key: key);

  @override
  _CreateUpdateriskViewState createState() => _CreateUpdateriskViewState();
}

class _CreateUpdateriskViewState extends State<CreateUpdateriskView> {
  Cloudrisk? _risk;
  late final FirebaseCloudStorage _risksService;
  late final TextEditingController _typeController;
  late final TextEditingController _subtypeController;
  late final TextEditingController _dangerController;
  late final TextEditingController _jobprofileController;

  @override
  void initState() {
    _risksService = FirebaseCloudStorage();
    _typeController = TextEditingController();
    _subtypeController = TextEditingController();
    _dangerController = TextEditingController();
    _jobprofileController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final risk = _risk;
    if (risk == null) {
      return;
    }
    final type = _typeController.text;
    final subtype = _subtypeController.text;
    final danger = _dangerController.text;
    final jobprofile = _jobprofileController.text;
    await _risksService.updaterisk(
      documentId: risk.documentId,
      type: type,
      subtype: subtype,
      danger: danger,
      jobprofile: jobprofile,
    );
  }

  void _setupTextControllerListener() {
    _typeController.removeListener(_textControllerListener);
    _typeController.addListener(_textControllerListener);
    _subtypeController.removeListener(_textControllerListener);
    _subtypeController.addListener(_textControllerListener);
    _dangerController.removeListener(_textControllerListener);
    _dangerController.addListener(_textControllerListener);
    _jobprofileController.removeListener(_textControllerListener);
    _jobprofileController.addListener(_textControllerListener);
  }

  Future<Cloudrisk> createOrGetExistingRisk(BuildContext context) async {
    final widgetrisk = context.getArgument<Cloudrisk>();

    if (widgetrisk != null) {
      _risk = widgetrisk;
      _typeController.text = widgetrisk.type;
      _subtypeController.text = widgetrisk.subtype;
      _dangerController.text = widgetrisk.danger;
      _jobprofileController.text = widgetrisk.jobprofiles;
      return widgetrisk;
    }

    final existingrisk = _risk;
    if (existingrisk != null) {
      return existingrisk;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newrisk = await _risksService.createNewrisk(ownerUserId: userId);
    _risk = newrisk;
    return newrisk;
  }

  void _deleteriskIfTextIsEmpty() {
    final risk = _risk;
    if (_typeController.text.isEmpty && risk != null) {
      _risksService.deleterisk(documentId: risk.documentId);
    }
  }

  void _saveriskIfTextriskmpty() async {
    final risk = _risk;
    final type = _typeController.text;
    final subtype = _subtypeController.text;
    final danger = _dangerController.text;
    final jobprfile = _jobprofileController.text;
    if (risk != null && type.isEmpty) {
      await _risksService.updaterisk(
        documentId: risk.documentId,
        type: type,
        subtype: subtype,
        danger: danger,
        jobprofile: jobprfile,
      );
    }
  }

  @override
  void dispose() {
    _deleteriskIfTextIsEmpty();
    _saveriskIfTextriskmpty();
    _typeController.dispose();
    _subtypeController.dispose();
    _dangerController.dispose();
    _jobprofileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.loc.risk,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final type = _typeController.text;
              final subtype = _subtypeController.text;
              final danger = _dangerController.text;
              final jobprofile = _jobprofileController.text;
              if (_risk == null || type.isEmpty) {
                await showCannotShareEmptyriskDialog(context);
              } else {
                Share.share(type);
                Share.share(subtype);
                Share.share(danger);
                Share.share(jobprofile);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingRisk(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Column(
                children: [
                  TextField(
                    controller: _typeController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    maxLength: 20,
                    decoration: InputDecoration(
                      hintText: context.loc.start_typing_your_risk,
                    ),
                  ),
                  TextField(
                    controller: _subtypeController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    maxLength: 20,
                    decoration: InputDecoration(
                      hintText: context.loc.start_typing_your_risk,
                    ),
                  ),
                  TextField(
                    controller: _dangerController,
                    keyboardType: TextInputType.multiline,
                    maxLength: 2,
                    decoration: InputDecoration(
                      hintText: context.loc.start_typing_your_risk,
                    ),
                  ),
                  TextField(
                    controller: _jobprofileController,
                    keyboardType: TextInputType.multiline,
                    maxLength: 4,
                    decoration: InputDecoration(
                      hintText: context.loc.start_typing_your_risk,
                    ),
                  ),
                ],
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

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
  late final TextEditingController _textController;

  @override
  void initState() {
    _risksService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final risk = _risk;
    if (risk == null) {
      return;
    }
    final text = _textController.text;
    await _risksService.updaterisk(
      documentId: risk.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<Cloudrisk> createOrGetExistingrisk(BuildContext context) async {
    final widgetrisk = context.getArgument<Cloudrisk>();

    if (widgetrisk != null) {
      _risk = widgetrisk;
      _textController.text = widgetrisk.text;
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
    if (_textController.text.isEmpty && risk != null) {
      _risksService.deleterisk(documentId: risk.documentId);
    }
  }

  void _saveriskIfTextriskmpty() async {
    final risk = _risk;
    final text = _textController.text;
    if (risk != null && text.isEmpty) {
      await _risksService.updaterisk(
        documentId: risk.documentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteriskIfTextIsEmpty();
    _saveriskIfTextriskmpty();
    _textController.dispose();
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
              final text = _textController.text;
              if (_risk == null || text.isEmpty) {
                await showCannotShareEmptyriskDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingrisk(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: context.loc.start_typing_your_risk,
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

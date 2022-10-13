import 'package:flutter/material.dart';
import 'package:my_app/services/crud/user_service.dart';

import '../../services/auth/auth_service.dart';
import '../../services/crud/risk_service.dart';

class NewRiskView extends StatefulWidget {
  const NewRiskView({Key? key}) : super(key: key);

  @override
  State<NewRiskView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewRiskView> {
  DataBaseRisk? _risk;
  late final RiskService _riskService;
  late final UserService _userService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _riskService = RiskService();
    _userService = UserService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final risk = _risk;
    if (risk == null) {
      return;
    }
    final text = _textController.text;
    await _riskService.updateRiskType(
      risk: risk,
      type: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DataBaseRisk> createNewRisk() async {
    final existingRisk = _risk;
    if (existingRisk != null) {
      return existingRisk;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _userService.getUser(email: email);
    return await _riskService.createRisk();
  }

  void _deleteNoteIfTextIsEmpty() {
    final risk = _risk;
    if (_textController.text.isEmpty && risk != null) {
      _riskService.deleteRisk(id: risk.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final risk = _risk;
    final text = _textController.text;
    if (risk != null && text.isNotEmpty) {
      await _riskService.updateRiskType(
        risk: risk,
        type: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New note'),
        ),
        body: FutureBuilder(
          future: createNewRisk(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _risk = snapshot.data as DataBaseRisk?;
                _setupTextControllerListener();
                return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Start typing your note...',
                  ),
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}

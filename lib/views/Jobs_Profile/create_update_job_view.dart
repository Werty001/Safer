import 'package:flutter/material.dart';
import 'package:my_app/extensions/buildcontext/loc.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/utilities/dialogs/cannot_share_empty_risk_dialog.dart';
import 'package:my_app/utilities/generics/get_arguments.dart';
import 'package:my_app/services/cloud/cloud_job_profiles.dart';
import 'package:my_app/services/cloud/firebase_cloud_jobs_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdatejobView extends StatefulWidget {
  const CreateUpdatejobView({Key? key}) : super(key: key);

  @override
  _CreateUpdatejobViewState createState() => _CreateUpdatejobViewState();
}

class _CreateUpdatejobViewState extends State<CreateUpdatejobView> {
  CloudJobProfile? _job;
  late final FirebaseCloudJobsStorage _jobsService;
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _riskController;
  late final TextEditingController _eppController;

  @override
  void initState() {
    _jobsService = FirebaseCloudJobsStorage();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _riskController = TextEditingController();
    _eppController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final job = _job;
    if (job == null) {
      return;
    }
    final name = _nameController.text;
    final desc = _descController.text;
    final risk = _riskController.text;
    final epp = _eppController.text;
    await _jobsService.updateJob(
      documentId: job.documentId,
      name: name,
      desc: desc,
      risk: risk,
      epp: epp,
    );
  }

  void _setupTextControllerListener() {
    _nameController.removeListener(_textControllerListener);
    _nameController.addListener(_textControllerListener);
    _descController.removeListener(_textControllerListener);
    _descController.addListener(_textControllerListener);
    _riskController.removeListener(_textControllerListener);
    _riskController.addListener(_textControllerListener);
    _eppController.removeListener(_textControllerListener);
    _eppController.addListener(_textControllerListener);
  }

  Future<CloudJobProfile> createOrGetExistingJob(BuildContext context) async {
    final widgetJob = context.getArgument<CloudJobProfile>();

    if (widgetJob != null) {
      _job = widgetJob;
      _nameController.text = widgetJob.jobName;
      _descController.text = widgetJob.jobDescription;
      _riskController.text = widgetJob.riskLinked;
      _eppController.text = widgetJob.eppLinked;
      return widgetJob;
    }

    final existingJob = _job;
    if (existingJob != null) {
      return existingJob;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newJob = await _jobsService.createNewJob(ownerUserId: userId);
    _job = newJob;
    return newJob;
  }

  void _deleteJobIfTextIsEmpty() {
    final job = _job;
    if (_nameController.text.isEmpty && job != null) {
      _jobsService.deleteJob(documentId: job.documentId);
    }
  }

  void _saveJobIfTextisEmpty() async {
    final job = _job;
    final name = _nameController.text;
    final desc = _descController.text;
    final risk = _riskController.text;
    final epp = _eppController.text;
    if (job != null && name.isEmpty) {
      await _jobsService.updateJob(
        documentId: job.documentId,
        name: name,
        desc: desc,
        risk: risk,
        epp: epp,
      );
    }
  }

  @override
  void dispose() {
    _deleteJobIfTextIsEmpty();
    _saveJobIfTextisEmpty();
    _nameController.dispose();
    _descController.dispose();
    _riskController.dispose();
    _eppController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jobs"),
        actions: [
          IconButton(
            onPressed: () async {
              final name = _nameController.text;
              final desc = _descController.text;
              final risk = _riskController.text;
              final epp = _eppController.text;
              if (_job == null || name.isEmpty) {
                await showCannotShareEmptyJobDialog(context);
              } else {
                Share.share(name);
                Share.share(desc);
                Share.share(risk);
                Share.share(epp);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingJob(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Column(
                children: [
                  TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    maxLength: 20,
                    decoration: InputDecoration(
                      hintText: context.loc.start_typing_your_risk,
                    ),
                  ),
                  TextField(
                    controller: _descController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: context.loc.start_typing_your_risk,
                    ),
                  ),
                  TextField(
                    controller: _riskController,
                    keyboardType: TextInputType.multiline,
                    maxLength: 2,
                    decoration: InputDecoration(
                      hintText: context.loc.start_typing_your_risk,
                    ),
                  ),
                  TextField(
                    controller: _eppController,
                    keyboardType: TextInputType.multiline,
                    maxLength: 2,
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

import 'package:flutter/material.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/extensions/buildcontext/loc.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/cloud/cloud_job_profiles.dart';
import 'package:my_app/services/cloud/firebase_cloud_jobs_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:my_app/views/Jobs_Profile/Job_profile_list_view.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class JobsView extends StatefulWidget {
  const JobsView({Key? key}) : super(key: key);

  @override
  _JobsViewState createState() => _JobsViewState();
}

class _JobsViewState extends State<JobsView> {
  late final FirebaseCloudJobsStorage _JobsService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _JobsService = FirebaseCloudJobsStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: _JobsService.allJobs(ownerUserId: userId).getLength,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              final JobCount = snapshot.data ?? 0;
              final text = "Jobs Profiles";
              return Text(text);
            } else {
              return const Text('');
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdatejobRoute);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _JobsService.allJobs(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allJobs = snapshot.data as Iterable<CloudJobProfile>;
                return JobListView(
                  jobs: allJobs,
                  onDeleteJob: (jobs) async {
                    await _JobsService.deleteJob(documentId: jobs.documentId);
                  },
                  onTap: (jobs) {
                    Navigator.of(context).pushNamed(
                      createOrUpdatejobRoute,
                      arguments: jobs,
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

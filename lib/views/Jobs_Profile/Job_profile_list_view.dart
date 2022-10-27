import 'package:flutter/material.dart';
import 'package:my_app/services/cloud/cloud_job_profiles.dart';
import 'package:my_app/utilities/dialogs/delete_dialog.dart';

typedef JobCallback = void Function(CloudJobProfile jobProfile);

class JobListView extends StatelessWidget {
  final Iterable<CloudJobProfile> jobs;
  final JobCallback onDeleteJob;
  final JobCallback onTap;

  const JobListView({
    Key? key,
    required this.jobs,
    required this.onDeleteJob,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(job);
          },
          title: Text(
            job.jobName,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteJob(job);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}

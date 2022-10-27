import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/services/cloud/cloud_job_profiles.dart';
import 'package:my_app/services/cloud/cloud_storage_constants.dart';
import 'package:my_app/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudJobsStorage {
  final jobs = FirebaseFirestore.instance.collection('job profiles');

  Future<void> deleteJob({required String documentId}) async {
    try {
      await jobs.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteriskException();
    }
  }

  Future<void> updateJob({
    required String documentId,
    required String name,
    required String desc,
    required String risk,
    required String epp,
  }) async {
    try {
      await jobs.doc(documentId).update({
        jobnameFieldName: name,
        jobdescriptionFieldName: desc,
        riskLinkedFieldName: risk,
        eppLinkedFieldName: epp,
      });
    } catch (e) {
      throw CouldNotUpdateriskException();
    }
  }

  Stream<Iterable<CloudJobProfile>> allJobs({required String ownerUserId}) {
    final alljobs = jobs
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) =>
            event.docs.map((doc) => CloudJobProfile.fromSnapshot(doc)));
    return alljobs;
  }

  Future<CloudJobProfile> createNewJob({required String ownerUserId}) async {
    final document = await jobs.add({
      jobnameFieldName: '',
      jobdescriptionFieldName: '',
      riskLinkedFieldName: '0',
      eppLinkedFieldName: '0',
    });
    final fetchedjob = await document.get();
    return CloudJobProfile(
      documentId: fetchedjob.id,
      jobName: '',
      jobDescription: '',
      riskLinked: '0',
      eppLinked: '0',
    );
  }

  static final FirebaseCloudJobsStorage _shared =
      FirebaseCloudJobsStorage._sharedInstance();
  FirebaseCloudJobsStorage._sharedInstance();
  factory FirebaseCloudJobsStorage() => _shared;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudJobProfile {
  final String documentId;
  final String jobName;
  final String jobDescription;
  final String riskLinked;
  final String eppLinked;

  const CloudJobProfile({
    required this.documentId,
    required this.jobName,
    required this.jobDescription,
    required this.riskLinked,
    required this.eppLinked,
  });

  CloudJobProfile.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        jobName = snapshot.data()[jobnameFieldName] as String,
        jobDescription = snapshot.data()[jobdescriptionFieldName] as String,
        riskLinked = snapshot.data()[riskLinkedFieldName] as String,
        eppLinked = snapshot.data()[eppLinkedFieldName] as String;
}

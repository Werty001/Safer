import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudRisk {
  final String documentId;
  final String ownerUserId;
  final String type;
  final String subtype;
  final String danger;
  final String jobprofiles;

  const CloudRisk({
    required this.documentId,
    required this.ownerUserId,
    required this.type,
    required this.subtype,
    required this.danger,
    required this.jobprofiles,
  });

  CloudRisk.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        type = snapshot.data()[typeFieldName] as String,
        subtype = snapshot.data()[subtypeFieldName] as String,
        danger = snapshot.data()[dangerFieldName] as String,
        jobprofiles = snapshot.data()[jobprofileFieldName] as String;
}

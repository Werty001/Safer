import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class Cloudrisk {
  final String documentId;
  final String ownerUserId;
  final String text;
  const Cloudrisk({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  Cloudrisk.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/services/cloud/cloud_risk.dart';
import 'package:my_app/services/cloud/cloud_storage_constants.dart';
import 'package:my_app/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final risks = FirebaseFirestore.instance.collection('risks');

  Future<void> deleterisk({required String documentId}) async {
    try {
      await risks.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteriskException();
    }
  }

  Future<void> updaterisk({
    required String documentId,
    required String type,
    required String subtype,
    required String danger,
    required String jobprofile,
  }) async {
    try {
      await risks.doc(documentId).update({
        typeFieldName: type,
        subtypeFieldName: subtype,
        dangerFieldName: danger,
        jobprofileFieldName: jobprofile,
      });
    } catch (e) {
      throw CouldNotUpdateriskException();
    }
  }

  Stream<Iterable<Cloudrisk>> allrisks({required String ownerUserId}) {
    final allrisks = risks
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => Cloudrisk.fromSnapshot(doc)));
    return allrisks;
  }

  Future<Cloudrisk> createNewrisk({required String ownerUserId}) async {
    final document = await risks.add({
      ownerUserIdFieldName: ownerUserId,
      typeFieldName: '',
      subtypeFieldName: '',
      dangerFieldName: '0',
      jobprofileFieldName: '0',
    });
    final fetchedrisk = await document.get();
    return Cloudrisk(
      documentId: fetchedrisk.id,
      ownerUserId: ownerUserId,
      type: '',
      subtype: '',
      danger: '0',
      jobprofiles: '0',
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}

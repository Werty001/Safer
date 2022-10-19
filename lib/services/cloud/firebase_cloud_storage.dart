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
    required String text,
  }) async {
    try {
      await risks.doc(documentId).update({textFieldName: text});
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
      textFieldName: '',
    });
    final fetchedrisk = await document.get();
    return Cloudrisk(
      documentId: fetchedrisk.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}

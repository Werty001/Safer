import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_app/extensions/list/filter.dart';
import 'package:my_app/services/crud/crud_exceptions.dart';
import 'package:my_app/services/crud/user_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class risksService {
  Database? _db;

  List<RiskModel> _risks = [];

  UserModel? _user;

  static final risksService _shared = risksService._sharedInstance();
  risksService._sharedInstance() {
    _risksStreamController = StreamController<List<RiskModel>>.broadcast(
      onListen: () {
        _risksStreamController.sink.add(_risks);
      },
    );
  }
  factory risksService() => _shared;

  late final StreamController<List<RiskModel>> _risksStreamController;

  Stream<List<RiskModel>> get allrisks =>
      _risksStreamController.stream.filter((risk) {
        final currentUser = _user;
        if (currentUser != null) {
          return risk.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllrisks();
        }
      });

  Future<void> _cacherisks() async {
    final allrisks = await getAllrisks();
    _risks = allrisks.toList();
    _risksStreamController.add(_risks);
  }

  Future<RiskModel> updaterisk({
    required RiskModel risk,
    required String type,
    required String subtype,
    required String danger,
    required String jobprofile,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure risk exists
    await getrisk(id: risk.id);

    //update DB
    final updatesCount = await db.update(
      riskTable,
      {
        typeColumn: type,
        subtypeColumn: subtype,
        dangerColumn: danger,
        jobProfileColumn: jobprofile,
        isSyncedWithCloudColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [risk.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdaterisk();
    } else {
      final updatedrisk = await getrisk(id: risk.id);
      _risks.removeWhere((risk) => risk.id == updatedrisk.id);
      _risks.add(updatedrisk);
      _risksStreamController.add(_risks);
      return updatedrisk;
    }
  }

  Future<Iterable<RiskModel>> getAllrisks() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final risks = await db.query(riskTable);

    return risks.map((riskRow) => RiskModel.fromRow(riskRow));
  }

  Future<RiskModel> getrisk({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final risks = await db.query(
      riskTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (risks.isEmpty) {
      throw CouldNotFindrisk();
    } else {
      final risk = RiskModel.fromRow(risks.first);
      _risks.removeWhere((risk) => risk.id == id);
      _risks.add(risk);
      _risksStreamController.add(_risks);
      return risk;
    }
  }

  Future<int> deleteAllrisks() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(riskTable);
    _risks = [];
    _risksStreamController.add(_risks);
    return numberOfDeletions;
  }

  Future<void> deleterisk({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      riskTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleterisk();
    } else {
      _risks.removeWhere((risk) => risk.id == id);
      _risksStreamController.add(_risks);
    }
  }

  Future<UserModel> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return UserModel.fromRow(results.first);
    }
  }

  Future<RiskModel> createrisk({required UserModel owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const type = '';
    const subtype = '';
    //create the risk
    final riskId = await db.insert(riskTable, {
      userIdColumn: owner.id,
      typeColumn: type,
      subtypeColumn: subtype,
      dangerColumn: 0,
      jobProfileColumn: 0,
      isSyncedWithCloudColumn: 1,
    });

    final risk = RiskModel(
      id: riskId,
      userId: owner.id,
      type: type,
      subtype: subtype,
      danger: '0',
      jobprofile: '0',
      isSyncedWithCloud: true,
    );

    _risks.add(risk);
    _risksStreamController.add(_risks);

    return risk;
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      //create risk table
      await db.execute(createriskTable);
      await _cacherisks();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

class RiskModel {
  final int id;
  final int userId;
  final String type;
  final String subtype;
  final String danger;
  final String jobprofile;
  final bool isSyncedWithCloud;

  RiskModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.subtype,
    required this.danger,
    required this.jobprofile,
    required this.isSyncedWithCloud,
  });

  RiskModel.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        type = map[typeColumn] as String,
        subtype = map[subtypeColumn] as String,
        danger = map[dangerColumn] as String,
        jobprofile = map[jobProfileColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'risk, ID = $id, userId = $userId, type = $type, subtype = $subtype, danger = $danger, job profiles = $jobprofile, isSyncedWithCloud = $isSyncedWithCloud';

  @override
  bool operator ==(covariant RiskModel other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'Safer.db';
const riskTable = 'risk';
const idColumn = 'id';
const userIdColumn = 'user_id';
const typeColumn = 'type';
const subtypeColumn = 'sub_type';
const dangerColumn = 'danger';
const jobProfileColumn = 'job_profile';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

const createriskTable = '''CREATE TABLE IF NOT EXISTS "risk" (
         "id"	INTEGER NOT NULL,
         "user_id"	INTEGER NOT NULL,
         "type"	TEXT,
         "sub_type"	TEXT,
         "danger"	TEXT,
         "job_profile" TEXT,
         "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
         FOREIGN KEY("user_id") REFERENCES "user"("id"),
         PRIMARY KEY("id" AUTOINCREMENT)
       );''';

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:my_app/extensions/list/filter.dart';
import 'package:my_app/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class risksService {
  Database? _db;

  List<Databaserisk> _risks = [];

  DatabaseUser? _user;

  static final risksService _shared = risksService._sharedInstance();
  risksService._sharedInstance() {
    _risksStreamController = StreamController<List<Databaserisk>>.broadcast(
      onListen: () {
        _risksStreamController.sink.add(_risks);
      },
    );
  }
  factory risksService() => _shared;

  late final StreamController<List<Databaserisk>> _risksStreamController;

  Stream<List<Databaserisk>> get allrisks =>
      _risksStreamController.stream.filter((risk) {
        final currentUser = _user;
        if (currentUser != null) {
          return risk.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllrisks();
        }
      });

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacherisks() async {
    final allrisks = await getAllrisks();
    _risks = allrisks.toList();
    _risksStreamController.add(_risks);
  }

  Future<Databaserisk> updaterisk({
    required Databaserisk risk,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure risk exists
    await getrisk(id: risk.id);

    //update DB
    final updatesCount = await db.update(
      riskTable,
      {
        textColumn: text,
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

  Future<Iterable<Databaserisk>> getAllrisks() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final risks = await db.query(riskTable);

    return risks.map((riskRow) => Databaserisk.fromRow(riskRow));
  }

  Future<Databaserisk> getrisk({required int id}) async {
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
      final risk = Databaserisk.fromRow(risks.first);
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

  Future<Databaserisk> createrisk({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    //create the risk
    final riskId = await db.insert(riskTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final risk = Databaserisk(
      id: riskId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _risks.add(risk);
    _risksStreamController.add(_risks);

    return risk;
  }

  Future<DatabaseUser> getUser({required String email}) async {
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
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
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
      //create the user table
      await db.execute(createUserTable);
      //create risk table
      await db.execute(createriskTable);
      await _cacherisks();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Databaserisk {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  Databaserisk({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  Databaserisk.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'risk, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant Databaserisk other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'risks.db';
const riskTable = 'risk';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
         "id"	INTEGER NOT NULL,
         "email"	TEXT NOT NULL UNIQUE,
         PRIMARY KEY("id" AUTOINCREMENT)
       );''';
const createriskTable = '''CREATE TABLE IF NOT EXISTS "risk" (
         "id"	INTEGER NOT NULL,
         "user_id"	INTEGER NOT NULL,
         "text"	TEXT,
         "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
         FOREIGN KEY("user_id") REFERENCES "user"("id"),
         PRIMARY KEY("id" AUTOINCREMENT)
       );''';

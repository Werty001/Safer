import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:my_app/extensions/list/filter.dart';
import 'package:my_app/services/crud/crud_exceptions.dart';
import 'package:my_app/services/crud/risk_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class userService {
  Database? _db;

  List<RiskModel> _risks = [];

  UserModel? _user;

  static final userService _shared = userService._sharedInstance();
  userService._sharedInstance() {
    _risksStreamController = StreamController<List<RiskModel>>.broadcast(
      onListen: () {
        _risksStreamController.sink.add(_risks);
      },
    );
  }
  factory userService() => _shared;

  late final StreamController<List<RiskModel>> _risksStreamController;

  Future<UserModel> getOrCreateUser({
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

  Future<UserModel> createUser({required String email}) async {
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

    return UserModel(
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
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class UserModel {
  final int id;
  final String email;
  const UserModel({
    required this.id,
    required this.email,
  });

  UserModel.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant UserModel other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'Safer.db';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';

const isSyncedWithCloudColumn = 'is_synced_with_cloud';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
         "id"	INTEGER NOT NULL,
         "email"	TEXT NOT NULL UNIQUE,
         PRIMARY KEY("id" AUTOINCREMENT)
       );''';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'risk_service.dart';
import 'crud_exceptions.dart';

class UserService {
  Database? _db;

  Future<DataBaseUser> getUserOrCreate({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      await _ensureDbIsOpen();
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

//Grab a User whith a particular 'email'
  Future<DataBaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatbaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DataBaseUser.fromRow(result.first);
    }
  }

//Create USER if not already exist in the DB or throw an error
  Future<DataBaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatbaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExist();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DataBaseUser(
      id: userId,
      email: email,
      name: "name",
      verif: false,
      audit: false,
      admin: false,
      profile: 0,
      location: 0,
      usersync: false,
    );
  }

//Delete USER using email adress
  Future<void> deleteUser({required String email}) async {
    final db = _getDatbaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  //Function that return a DB or auto manage a Exeption
  Database _getDatbaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

//Close the Database
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

//Ensuting that th DB is already open
  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DataBaseAlreadyOpenException {
      //empty
    }
  }

//Open the Database
  Future<void> open() async {
    if (_db != null) {
      throw DataBaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      //Create USER table
      await db.execute(createUserTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DataBaseUser {
  final int id;
  final String email;
  final String name;
  final bool verif;
  final bool audit;
  final bool admin;
  final int profile;
  final int location;
  final bool usersync;

  const DataBaseUser({
    required this.id,
    required this.email,
    required this.name,
    required this.verif,
    required this.audit,
    required this.admin,
    required this.profile,
    required this.location,
    required this.usersync,
  });

  DataBaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String,
        name = map[nameColumn] as String,
        verif = (map[verifColumn] as int) == 1 ? true : false,
        audit = (map[auditColumn] as int) == 1 ? true : false,
        admin = (map[adminColumn] as int) == 1 ? true : false,
        profile = map[profileColumn] as int,
        location = map[locationColumn] as int,
        usersync = (map[syncColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Person, name: $name ID: $id, email: $email, verif: $verif, audit: $audit, admin: $admin, profile:$profile, location: $location, sync: $usersync';

  @override
  bool operator ==(covariant DataBaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'risk.db';
const userTable = 'user';
//USER Database Columns
const idColumn = 'user_id';
const emailColumn = 'user_email';
const nameColumn = 'user_name';
const verifColumn = 'user_verif';
const auditColumn = 'user_audit';
const adminColumn = 'user_admin';
const profileColumn = 'user_profile';
const trainingColumn = 'user_training';
const eppColumn = 'user_epp';
const locationColumn = 'user_location';
const syncColumn = 'sync';
//SQL Code to create tables
//USER TABLE
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	"user_id"	INTEGER NOT NULL,
	"user_email"	TEXT NOT NULL DEFAULT 'none' UNIQUE,
	"user_name"	TEXT NOT NULL DEFAULT 'none',
	"user_verif"	BLOB NOT NULL DEFAULT 'false',
	"user_audit"	BLOB NOT NULL DEFAULT 'false',
	"user_admin"	BLOB NOT NULL DEFAULT 'false',
	"user_profile"	INTEGER NOT NULL DEFAULT 'none',
	"user_location"	INTEGER NOT NULL DEFAULT 'none',
	"sync"	BLOB NOT NULL DEFAULT 'false',
	FOREIGN KEY("user_location") REFERENCES "location"("location_id"),
	FOREIGN KEY("user_profile") REFERENCES "job_profile"("profile_id"),
	PRIMARY KEY("user_id" AUTOINCREMENT)
);''';

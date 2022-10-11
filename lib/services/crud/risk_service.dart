import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';

class RiskService {
  Database? _db;

//Update a Risk type with a particular 'id'
  Future<DataBaseRisk> updateRiskType({
    required DataBaseRisk risk,
    required String type,
  }) async {
    final db = _getDatbaseOrThrow();
    await getRisk(id: risk.id);
    final updateCount = await db.update(riskTable, {
      riskTypeColumn: type,
      syncColumn: 0,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateRisk();
    } else {
      return await getRisk(id: risk.id);
    }
  }

//Grab all the notes in the Database
  Future<Iterable<DataBaseRisk>> getAllRisks() async {
    final db = _getDatbaseOrThrow();
    final risks = await db.query(riskTable);
    return risks.map((riskRow) => DataBaseRisk.fromRow(riskRow));
  }

//Grab a Risk with a particualr 'id'
  Future<DataBaseRisk> getRisk({required int id}) async {
    final db = _getDatbaseOrThrow();
    final risks = await db.query(
      riskTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (risks.isEmpty) {
      throw CouldNotFindRisk();
    }
    return DataBaseRisk.fromRow(risks.first);
  }

//Detelete all risk in the Database
  Future<int> deleteAllRisks() async {
    final db = _getDatbaseOrThrow();
    return await db.delete(riskTable);
  }

//Delete a Risk with a particualr 'id'
  Future<void> deleteRisk({required int id}) async {
    final db = _getDatbaseOrThrow();
    final deleteCount = await db.delete(
      riskTable,
      where: 'id =?',
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteRisk();
    }
  }

//Create a new risk checking if already exist
  Future<DataBaseRisk> createRisk({required DataBaseUser owner}) async {
    final db = _getDatbaseOrThrow();

    //Checking OWNER of the RISK
    //Make sure owner exists in the databasewith correct id
    /*
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    */
    final riskId = await db.insert(riskTable, {
      riskNameColumn: 'none',
      riskTypeColumn: '',
      riskSubTypeColumn: '',
      riskDamageColumn: 0,
      riskProfileColumn: 0,
      riskTrainingColumn: 0,
      riskLocationColumn: 0,
      riskEppColumn: 0,
      syncColumn: 1,
    });

    final risk = DataBaseRisk(
      id: riskId,
      riskName: '',
      riskType: '',
      riskSubType: '',
      riskDamage: 0,
      riskProfile: 0,
      riskTraining: 0,
      riskLocation: 0,
      riskEpp: 0,
      riskSync: true,
    );

    return risk;
  }

//Grab a User whith a particular 'email'
  Future<DataBaseUser> getUser({required String email}) async {
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
      //Create RISK table
      await db.execute(createRiskTable);
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

class DataBaseRisk {
  final int id;
  final String riskName;
  final String riskType;
  final String riskSubType;
  final int riskDamage;
  final int riskProfile;
  final int riskTraining;
  final int riskLocation;
  final int riskEpp;
  final bool riskSync;

  DataBaseRisk({
    required this.id,
    required this.riskName,
    required this.riskType,
    required this.riskSubType,
    required this.riskDamage,
    required this.riskProfile,
    required this.riskTraining,
    required this.riskLocation,
    required this.riskEpp,
    required this.riskSync,
  });

  DataBaseRisk.fromRow(Map<String, Object?> map)
      : id = map[idRiskColumn] as int,
        riskName = map[riskNameColumn] as String,
        riskType = map[riskTypeColumn] as String,
        riskSubType = map[riskSubTypeColumn] as String,
        riskDamage = map[riskDamageColumn] as int,
        riskProfile = map[riskProfileColumn] as int,
        riskTraining = map[riskTrainingColumn] as int,
        riskLocation = map[riskLocationColumn] as int,
        riskEpp = map[riskEppColumn] as int,
        riskSync = map[syncColumn] as bool;

  @override
  String toString() =>
      'Risk, ID: $id, Risk Type: $riskType, Risk Subtype: $riskSubType, Risk Damage Score: $riskDamage, Profiles: $riskProfile, Trainings: $riskTraining, Risk Location: $riskLocation, Risk Epp: $riskEpp';

  @override
  bool operator ==(covariant DataBaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'risk.db';
const riskTable = 'risk';
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
//RISK Database Columns
const idRiskColumn = 'risk_id';
const riskNameColumn = 'risk_name';
const riskTypeColumn = 'risk_type';
const riskSubTypeColumn = 'risk_subtype';
const riskDamageColumn = 'risk_damage';
const riskProfileColumn = 'risk_profile';
const riskTrainingColumn = 'risk_training';
const riskLocationColumn = 'risk_location';
const riskEppColumn = 'risk_epp';
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
//RISK TABLE
const createRiskTable = '''CREATE TABLE IF NOT EXISTS "risk" (
	"risk_id"	INTEGER,
	"risk_name"	TEXT NOT NULL DEFAULT 'none' UNIQUE,
	"risk_type"	TEXT NOT NULL DEFAULT 'none' UNIQUE,
	"risk_subtype"	TEXT NOT NULL DEFAULT 'none' UNIQUE,
	"risk_damage"	NUMERIC NOT NULL DEFAULT 1,
	"risk_profile"	INTEGER NOT NULL DEFAULT 'none',
	"risk_training"	INTEGER NOT NULL,
	"risk_location"	INTEGER NOT NULL,
	"risk_epp"	INTEGER NOT NULL,
	"sync"	INTEGER NOT NULL DEFAULT 'false',
	FOREIGN KEY("risk_profile") REFERENCES "job_profile"("profile_id"),
	FOREIGN KEY("risk_training") REFERENCES "trainings"("training_id"),
	FOREIGN KEY("risk_epp") REFERENCES "epp"("epp_id"),
	FOREIGN KEY("risk_location") REFERENCES "location"("location_id"),
	PRIMARY KEY("risk_id" AUTOINCREMENT)
);''';

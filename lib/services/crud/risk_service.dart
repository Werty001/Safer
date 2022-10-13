import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';
import 'user_service.dart';

class RiskService {
  Database? _db;
  List<DataBaseRisk> _risks = [];

//singleton in Flutter (whit this we can crate the isntance only one time)
  static final RiskService _shared = RiskService._sharedInstance();
  RiskService._sharedInstance();
  factory RiskService() => _shared;

  final _risksStreamController =
      StreamController<List<DataBaseRisk>>.broadcast();

  Future<void> _cacheRisks() async {
    final allRisks = await getAllRisks();
    _risks = allRisks.toList();
    _risksStreamController.add(_risks);
  }

//Update a Risk type with a particular 'id'
//FALTA AGREGAR EL RESTO DE LOS PARAMETROS
  Future<DataBaseRisk> updateRiskType({
    required DataBaseRisk risk,
    required String type,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatbaseOrThrow();
    await getRisk(id: risk.id);
    final updateCount = await db.update(riskTable, {
      riskTypeColumn: type,
      syncColumn: 0,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateRisk();
    } else {
      final updatedRisk = await getRisk(id: risk.id);
      _risks.removeWhere((risk) => risk.id == updatedRisk.id);
      _risks.add(updatedRisk);
      _risksStreamController.add(_risks);
      return updatedRisk;
    }
  }

//Grab all the risks listed on the DB
  Stream<List<DataBaseRisk>> get allRisks => _risksStreamController.stream;
//Grab all the notes in the Database
  Future<Iterable<DataBaseRisk>> getAllRisks() async {
    final db = _getDatbaseOrThrow();
    final risks = await db.query(riskTable);
    return risks.map((riskRow) => DataBaseRisk.fromRow(riskRow));
  }

//Grab a Risk with a particualr 'id'
  Future<DataBaseRisk> getRisk({required int id}) async {
    await _ensureDbIsOpen();
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
    final risk = DataBaseRisk.fromRow(risks.first);
    _risks.removeWhere((risk) => risk.id == id);
    _risks.add(risk);
    _risksStreamController.add(_risks);
    return risk;
  }

//Delete all risk in the Database
  Future<int> deleteAllRisks() async {
    await _ensureDbIsOpen();
    final db = _getDatbaseOrThrow();
    final numDeletions = await db.delete(riskTable);
    _risks = [];
    _risksStreamController.add(_risks);
    return numDeletions;
  }

//Delete a Risk with a particualr 'id'
  Future<void> deleteRisk({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatbaseOrThrow();
    final deleteCount = await db.delete(
      riskTable,
      where: 'id =?',
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteRisk();
    } else {
      _risks.removeWhere((risk) => risk.id == id);
      _risksStreamController.add(_risks);
    }
  }

//Create a new risk checking if already exist
  Future<DataBaseRisk> createRisk(/*{required DataBaseUser owner}*/) async {
    await _ensureDbIsOpen();
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
    _risks.add(risk);
    _risksStreamController.add(_risks);
    return risk;
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
      //Create RISK table
      await db.execute(createRiskTable);
      await _cacheRisks();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
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
  bool operator ==(covariant DataBaseRisk other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'risk.db';
const riskTable = 'risk';
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
const syncColumn = 'sync';
//SQL Code to create tables
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

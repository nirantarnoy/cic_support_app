import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_cic_support/models/inspectiontrans.dart';
import 'package:flutter_cic_support/sqlite/inspectionmodel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:flutter_cic_support/models/inspectiontrans.dart';

class DbProvider {
  static final DbProvider instance = DbProvider._init();
  static Database? _database;

  DbProvider._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cicsupport.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createTB);
  }

  Future _createTB(Database db, int version) async {
    final idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
    final TextType = "TEXT NOT NULL";
    final boolType = "BOOLEAN NOT NULL";
    final integerType = "INTEGER NOT NULL";
    final integernullType = "INTEGER";
    final floatType = "REAL";

    final String tableName = 'event_trans';
    await db.execute('''
    CREATE TABLE $tableName(
     id $idType,
     module_type_id $TextType,
     plan_id $TextType,
     trans_date $TextType,
     emp_id $TextType,
     area_group_id $TextType,
     area_id $TextType,
     team_id $TextType,
     topic_id $TextType,
     topic_item_id $TextType,
     scored $TextType,
     status $TextType,
     note $TextType,
     plan_num $TextType
    )
    ''');
  }

  Future<List<String>> getAllTableNames() async {
    final db = await instance.database;
    List<Map> maps =
        await db.rawQuery('SELECT * FROM sqlite_master ORDER BY name;');

    List<String> tableNameList = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        tableNameList.add(maps[i]['name'].toString());
        try {} catch (e) {
          print("Exception is ${e}");
        }
      }
    }
    return tableNameList;
  }

  Future<int> createInspectionTrans(InspectionTransDB data) async {
    final db = await instance.database;

    final id = await db.insert('event_trans', data.toJson());
    return id;
  }

  Future<List<Map<String, Object?>>> readinspectionAll() async {
    Database db = await instance.database;
    final orderBy = ' ASC';
    final result = await db.rawQuery('SELECT * FROM event_trans');
    return result;
    //return result.map((json) => InspectionTransDB.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> readinspectionWithTopic(
      String topic_item_id, String area_id) async {
    Database db = await instance.database;
    final orderBy = ' ASC';
    final result = await db.rawQuery(
        'SELECT * FROM event_trans WHERE topic_item_id=' +
            topic_item_id +
            " and area_id=" +
            area_id);
    return result;
    //return result.map((json) => InspectionTransDB.fromJson(json)).toList();
  }

  Future<bool> updateTransScore(String id_update, String score) async {
    Database db = await instance.database;
    final result = await db.rawUpdate(
        'UPDATE event_trans SET score=' + score + " WHERE id=" + id_update);

    return true;
  }

  Future<bool> addinspectionWithTopic(InspectionTrans data) async {
    Database db = await instance.database;
    String topic_id = data.topic_id;
    String topic_item_id = data.topic_item_id;
    String area_id = data.area_id;
    final result = await db.rawInsert(
        'INSERT INTO event_trans(module_type_id,plan_id,trans_date,emp_id,area_group_id,area_id,team_id,topic_id,topic_item_id,status,note,plan_num)VALUES(?,?,?,?,?,?,?,?,?,?,?,?)',
        [1, "1", '', '', '', '', '', '', '', '', '', '']);

    return true;
  }

  Future<int> countCheckedTopicitem(String area_id) async {
    Database db = await instance.database;
    int cnt = 0;
    final result = await db.rawQuery(
        'SELECT count(*) as cnt FROM envent_trans WHERE area_id = ?',
        [area_id]);

    for (var rows in result) {
      print('checked item is ${rows}');
    }
    return cnt;
  }

  Future<bool> clearTransData() async {
    final db = await instance.database;
    final result = await db.rawDelete('DELETE FROM event_trans');
    return true;
  }
}

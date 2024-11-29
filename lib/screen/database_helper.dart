import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'markers.db');

    // Check if the database exists
    bool dbExists = await databaseExists(path);

    if (!dbExists) {
      // If the database does not exist, copy it from the assets
      ByteData data = await rootBundle.load('assets/database/markers.db');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write the copied data to the database file
      await File(path).writeAsBytes(bytes);
      print('Database copied from assets to $path');
    } else {
      print('Database already exists at $path');
    }

    return await openDatabase(path, version: 1);
  }

  Future<void> insertMarker(Map<String, dynamic> marker) async {
    final db = await database;
    await db.insert(
      'markers',
      marker,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMarkers() async {
    final db = await database;
    return await db.query('markers');
  }

  Future<void> printAllMarkers() async {
    final db = await database;
    final List<Map<String, dynamic>> markers = await db.query('markers');
    markers.forEach((marker) {
      print(
          'Marker: ${marker['name']}, Latitude: ${marker['latitude']}, Longitude: ${marker['longitude']}');
    });
  }

  Future<bool> markerExists(double latitude, double longitude) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'markers',
      where: 'latitude = ? AND longitude = ?',
      whereArgs: [latitude, longitude],
    );

    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getMarkerById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'markers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<List<String>> getUniqueMainEventNames() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT DISTINCT main_event_nm FROM markers WHERE main_event_nm IS NOT NULL',
    );

    return result.map((row) => row['main_event_nm'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getMarkersByEvent(String eventName) async {
    final db = await database;
    return await db.query(
      'markers',
      where: 'main_event_nm = ?',
      whereArgs: [eventName],
    );
  }

  Future<List<Map<String, dynamic>>> getMarkersByName(String name) async {
    final db = await database;
    return await db.query(
      'markers',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
  }
}

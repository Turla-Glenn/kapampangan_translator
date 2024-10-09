import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kapampangan.db');

    // Check if database exists
    final exists = await databaseExists(path);
    if (!exists) {
      // Load the .sql file as a string
      String sqlScript = await rootBundle.loadString('assets/kapampangan.sql');

      // Create the database and execute the SQL script
      Database db = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
            List<String> statements = sqlScript.split(';');
            for (String statement in statements) {
              if (statement.trim().isNotEmpty) {
                await db.execute(statement);
              }
            }
          });
      return db;
    }

    // Open existing database
    return await openDatabase(path, version: 1);
  }

  Future<String?> getTranslation(String text, String fromLang, String toLang) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations', // Replace with your table name
      columns: [toLang], // Select the target language column
      where: '$fromLang = ?', // Look up based on source language column
      whereArgs: [text],
    );

    if (maps.isNotEmpty) {
      return maps.first[toLang] as String?;
    } else {
      return null; // No translation found
    }
  }
}

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('currensee.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Conversion history table
    await db.execute('''
      CREATE TABLE conversion_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT NOT NULL,
        base_currency TEXT NOT NULL,
        target_currency TEXT NOT NULL,
        amount REAL NOT NULL,
        converted_amount REAL NOT NULL,
        exchange_rate REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // Rate alerts table (for feature 6)
    await db.execute('''
      CREATE TABLE rate_alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT NOT NULL,
        base_currency TEXT NOT NULL,
        target_currency TEXT NOT NULL,
        target_rate REAL NOT NULL,
        is_above INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> closeDB() async {
    final db = await instance.database;
    db.close();
  }
}
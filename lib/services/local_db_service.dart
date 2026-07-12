import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('heliot_cache.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE api_cache (
  key TEXT PRIMARY KEY,
  data TEXT NOT NULL,
  updated_at INTEGER NOT NULL
)
''');
  }

  Future<dynamic> getCachedData(String key, {Duration maxAge = const Duration(hours: 12)}) async {
    try {
      final db = await instance.database;
      final maps = await db.query(
        'api_cache',
        columns: ['data', 'updated_at'],
        where: 'key = ?',
        whereArgs: [key],
      );

      if (maps.isNotEmpty) {
        final int updatedAt = maps.first['updated_at'] as int;
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        
        if (currentTime - updatedAt < maxAge.inMilliseconds) {
          return jsonDecode(maps.first['data'] as String);
        }
      }
    } catch (e) {
      // Return null on failure
    }
    return null;
  }

  Future<void> saveToCache(String key, dynamic data) async {
    try {
      final db = await instance.database;
      final String jsonData = jsonEncode(data);
      final int currentTime = DateTime.now().millisecondsSinceEpoch;

      await db.insert(
        'api_cache',
        {
          'key': key,
          'data': jsonData,
          'updated_at': currentTime,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Ignore cache write error
    }
  }

  Future<void> clearCache() async {
    final db = await instance.database;
    await db.delete('api_cache');
  }
}

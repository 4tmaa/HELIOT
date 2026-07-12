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

  Future<dynamic> getCachedData(String key, {Duration? maxAge}) async {
    try {
      final db = await instance.database;
      final maps = await db.query(
        'api_cache',
        columns: ['data', 'updated_at'],
        where: 'key = ?',
        whereArgs: [key],
      );

      if (maps.isNotEmpty) {
        if (maxAge == null) {
          return jsonDecode(maps.first['data'] as String);
        }
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

  String getMaxUpdatedAt(List<dynamic> data, {String timeKey = 'updated_at', String fallbackKey = 'created_at'}) {
    if (data.isEmpty) return DateTime(2000).toIso8601String();
    
    DateTime maxTime = DateTime(2000);
    for (var item in data) {
      final timeStr = item[timeKey] ?? item[fallbackKey];
      if (timeStr != null) {
        final time = DateTime.tryParse(timeStr.toString());
        if (time != null && time.isAfter(maxTime)) {
          maxTime = time;
        }
      }
    }
    return maxTime.toIso8601String();
  }

  List<dynamic> mergeData(List<dynamic> oldData, List<dynamic> newData, {String primaryKey = 'id'}) {
    final Map<String, dynamic> mergedMap = {};
    
    for (var item in oldData) {
      if (item[primaryKey] != null) {
        mergedMap[item[primaryKey].toString()] = item;
      }
    }
    
    for (var item in newData) {
      if (item[primaryKey] != null) {
        mergedMap[item[primaryKey].toString()] = item;
      }
    }
    
    return mergedMap.values.toList();
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

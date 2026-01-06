import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'image_compose_entity.dart';

class DBImageCompose extends GetxService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> init() async {
    await database;
  }

  Future<Database> _initDatabase() async {
    String path = join(await sqflite.getDatabasesPath(), 'image_compose.db');
    return await sqflite.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE image_compose_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<List<ImageComposeEntity>> getImageComposeRecords() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'image_compose_records',
        orderBy: 'created_at DESC, id DESC',
      );
      return List.generate(maps.length, (i) {
        return ImageComposeEntity.fromMap(maps[i]);
      });
    } catch (e) {
      return [];
    }
  }

  Future<int> insertImageComposeRecord(ImageComposeEntity record) async {
    try {
      final db = await database;
      return await db.insert('image_compose_records', record.toMap());
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteImageComposeRecord(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'image_compose_records',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<void> cleanAllData () async {
    try {
      final db = await database;
      await db.delete('image_compose_records');
    } catch (e) {
      return;
    }
  }
}


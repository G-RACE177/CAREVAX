import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HouseholdsDB {
  static final HouseholdsDB instance = HouseholdsDB._init();
  static Database? _database;

  HouseholdsDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('households.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE households (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  address TEXT,
  members INTEGER,
  children INTEGER,
  lastVisit TEXT,
  status TEXT
)
''');
  }

  Future<int> create(Map<String, dynamic> household) async {
    final db = await instance.database;
    return await db.insert('households', household);
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final db = await instance.database;
    return await db.query('households', orderBy: 'id DESC');
  }

  Future<int> update(int id, Map<String, dynamic> household) async {
    final db = await instance.database;
    return await db.update('households', household, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('households', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

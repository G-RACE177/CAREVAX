import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class VisitsDB {
  static final VisitsDB instance = VisitsDB._init();
  static Database? _database;

  VisitsDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('visits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE visits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  guardian TEXT,
  status TEXT,
  date TEXT
)
''');
  }

  Future<int> create(Map<String, dynamic> visit) async {
    final db = await instance.database;
    return await db.insert('visits', visit);
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final db = await instance.database;
    final result = await db.query('visits', orderBy: 'id DESC');
    return result;
  }

  Future<int> update(int id, Map<String, dynamic> visit) async {
    final db = await instance.database;
    return await db.update('visits', visit, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('visits', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

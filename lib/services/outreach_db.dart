import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OutreachDB {
  static final OutreachDB instance = OutreachDB._init();
  static Database? _database;

  OutreachDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('outreach.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE outreach (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  location TEXT,
  date TEXT,
  time TEXT,
  target TEXT,
  status TEXT
)
''');
  }

  Future<int> create(Map<String, dynamic> outreach) async {
    final db = await instance.database;
    return await db.insert('outreach', outreach);
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final db = await instance.database;
    return await db.query('outreach', orderBy: 'id DESC');
  }

  Future<int> update(int id, Map<String, dynamic> outreach) async {
    final db = await instance.database;
    return await db.update('outreach', outreach, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('outreach', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

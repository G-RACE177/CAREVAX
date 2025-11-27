import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppointmentsDB {
  static final AppointmentsDB instance = AppointmentsDB._init();
  static Database? _database;

  AppointmentsDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('appointments.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE appointments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  childName TEXT NOT NULL,
  parentName TEXT,
  date TEXT,
  time TEXT,
  type TEXT,
  vaccine TEXT,
  status TEXT,
  notes TEXT
)
''');
  }

  Future<int> create(Map<String, dynamic> appointment) async {
    final db = await instance.database;
    return await db.insert('appointments', appointment);
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final db = await instance.database;
    return await db.query('appointments', orderBy: 'id DESC');
  }

  Future<int> update(int id, Map<String, dynamic> appointment) async {
    final db = await instance.database;
    return await db.update('appointments', appointment, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

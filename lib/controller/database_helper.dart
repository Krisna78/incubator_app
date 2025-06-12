import 'package:incubator_app/model/incubator.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('incubator.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const String sql = '''
    CREATE TABLE tb_incubator (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kode TEXT NOT NULL,
      tanggal_masuk TEXT NULL,
      tanggal_keluar TEXT NULL,
      jumlah_telur INTEGER NOT NULL
    );
    ''';
    await db.execute(sql);
  }

  Future<void> insertIncubator(Incubator incubator) async {
    final db = await instance.database;
    await db.insert(
      'tb_incubator',
      incubator.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Incubator?> fetchIncubatorById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'tb_incubator',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Incubator.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateIncubator(Incubator income) async {
    final db = await database;
    await db.update(
      'tb_incubator',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  Future<int> deleteIncubator(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tb_incubator',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getGroupedTelurData() async {
    final db = await instance.database;
    final data = await db.query('tb_incubator');

    Map<String, int> masukMap = {};
    Map<String, int> keluarMap = {};

    for (var row in data) {
      final jumlah = (row['jumlah_telur'] ?? 0) as int;
      final masuk = row['tanggal_masuk'] as String?;
      final keluar = row['tanggal_keluar'] as String?;

      if (masuk != null && masuk.isNotEmpty) {
        masukMap[masuk] = (masukMap[masuk] ?? 0) + jumlah;
      }

      if (keluar != null && keluar.isNotEmpty) {
        keluarMap[keluar] = (keluarMap[keluar] ?? 0) + jumlah;
      }
    }

    final allDates = {...masukMap.keys, ...keluarMap.keys}.toList()..sort();

    return allDates.map((tgl) {
      return {
        'tanggal': tgl,
        'masuk': masukMap[tgl] ?? 0,
        'keluar': keluarMap[tgl] ?? 0,
      };
    }).toList();
  }

  Future<List<Incubator>> getAllIncubators() async {
    final db = await instance.database;
    final result = await db.query('tb_incubator');

    return result.map((map) => Incubator.fromMap(map)).toList();
  }
}

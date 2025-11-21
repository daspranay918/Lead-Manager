import 'package:lead_manager/models/lead.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  // Singleton instance
  static final DBService instance = DBService._internal();
  DBService._internal();

  static Database? _db;

  // Get database
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // Initialize DB
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "leads.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE leads (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            contact TEXT,
            notes TEXT,
            status TEXT
          )
        ''');
      },
    );
  }

  // INSERT LEAD
  Future<int> insertLead(Lead lead) async {
    final db = await database;
    return await db.insert('leads', lead.toMap());
  }

  // GET ALL LEADS (non-paginated)
  Future<List<Lead>> getLeads() async {
    final db = await database;
    final result = await db.query('leads', orderBy: 'id DESC');
    return result.map((e) => Lead.fromMap(e)).toList();
  }

  // PAGINATED FETCH (for infinite scroll)
  Future<List<Lead>> getLeadsPaginated(int offset, int limit) async {
    final db = await database;
    final result = await db.query(
      'leads',
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((map) => Lead.fromMap(map)).toList();
  }

  // UPDATE LEAD
  
  Future<int> updateLead(Lead lead) async {
    final db = await database;

    return await db.update(
      'leads',
      lead.toMap(),
      where: 'id = ?',
      whereArgs: [lead.id],
    );
  }

  // DELETE LEAD
  
  Future<int> deleteLead(int id) async {
    final db = await database;
    return await db.delete(
      'leads',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

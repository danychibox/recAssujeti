import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:assujtiapp/model/boutique.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'recensement_beni.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE boutiques(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        proprietaire TEXT NOT NULL,
        telephone TEXT NOT NULL,
        adresse TEXT NOT NULL,
        quartier TEXT NOT NULL,
        typeCommerce TEXT NOT NULL,
        dateOuverture TEXT NOT NULL,
        nombreEmployes INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        dateRecensement TEXT NOT NULL
      )
    ''');
  }

  // CRUD operations
  Future<int> insertBoutique(Boutique boutique) async {
    final db = await database;
    return await db.insert('boutiques', boutique.toMap());
  }

  Future<List<Boutique>> getBoutiques() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('boutiques');
    return List.generate(maps.length, (i) => Boutique.fromMap(maps[i]));
  }

  Future<List<Boutique>> getBoutiquesByQuartier(String quartier) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'boutiques',
      where: 'quartier = ?',
      whereArgs: [quartier],
    );
    return List.generate(maps.length, (i) => Boutique.fromMap(maps[i]));
  }

  Future<int> updateBoutique(Boutique boutique) async {
    final db = await database;
    return await db.update(
      'boutiques',
      boutique.toMap(),
      where: 'id = ?',
      whereArgs: [boutique.id],
    );
  }

  Future<int> deleteBoutique(int id) async {
    final db = await database;
    return await db.delete(
      'boutiques',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTotalBoutiques() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM boutiques')
    );
    return count ?? 0;
  }
}
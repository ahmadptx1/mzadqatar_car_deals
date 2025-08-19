import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/car_listing.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('car_listings.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE car_listings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        price INTEGER,
        imageUrl TEXT,
        url TEXT,
        postedAt TEXT
      )
    ''');
  }

  Future<int> insertListing(CarListing listing) async {
    final db = await instance.database;
    return await db.insert('car_listings', listing.toMap());
  }

  Future<List<CarListing>> getListings() async {
    final db = await instance.database;
    final result = await db.query('car_listings', orderBy: 'postedAt DESC');
    return result.map((json) => CarListing.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
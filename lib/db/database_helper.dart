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

  return await openDatabase(path, version: 1, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE car_listings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT UNIQUE,
        title TEXT,
        description TEXT,
        price INTEGER,
        imageUrl TEXT,
        url TEXT,
        postedAt TEXT,
        dateOfAdvertiseEpoch INTEGER,
        sellerId TEXT,
        sellerName TEXT,
        isCompany INTEGER,
        km INTEGER,
        manufactureYear INTEGER,
        model TEXT,
        cityName TEXT,
        images TEXT,
        rawJson TEXT,
        recommended INTEGER DEFAULT 0,
        notifiedAt TEXT,
        badDeal INTEGER DEFAULT 0,
        approached INTEGER DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_car_listings_postedAt ON car_listings(postedAt)');
    await db.execute('CREATE INDEX idx_car_listings_sellerId ON car_listings(sellerId)');
  }

  // Support migrations in future by handling onUpgrade
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Placeholder: for now, db starts at version 1 with new schema. Implement migration if needed.
  }

  Future<int> insertListing(CarListing listing) async {
    final db = await instance.database;
    // Use insert with conflictAlgorithm to replace/update existing productId
    return await db.insert('car_listings', listing.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CarListing>> getListings() async {
    final db = await instance.database;
    final result = await db.query('car_listings', orderBy: 'postedAt DESC');
    return result.map((json) => CarListing.fromMap(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getListingsRaw({String? where, List<dynamic>? whereArgs}) async {
    final db = await instance.database;
    final result = await db.query('car_listings', where: where, whereArgs: whereArgs);
    return result;
  }

  Future<Map<String, dynamic>?> getListingByProductId(String productId) async {
    final db = await instance.database;
    final result = await db.query('car_listings', where: 'productId = ?', whereArgs: [productId], limit: 1);
    if (result.isEmpty) return null;
    return result.first;
  }

  Future<int> markRecommended(String productId, int recommended) async {
    final db = await instance.database;
    return await db.update('car_listings', {'recommended': recommended}, where: 'productId = ?', whereArgs: [productId]);
  }

  Future<int> markBadDeal(String productId, int badDeal) async {
    final db = await instance.database;
    return await db.update('car_listings', {'badDeal': badDeal}, where: 'productId = ?', whereArgs: [productId]);
  }

  Future<int> markApproached(String productId, int approached) async {
    final db = await instance.database;
    return await db.update('car_listings', {'approached': approached}, where: 'productId = ?', whereArgs: [productId]);
  }

  Future<int> updateNotifiedAt(String productId, String isoTimestamp) async {
    final db = await instance.database;
    return await db.update('car_listings', {'notifiedAt': isoTimestamp}, where: 'productId = ?', whereArgs: [productId]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
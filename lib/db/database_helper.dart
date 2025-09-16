import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/car_listing.dart';
import '../models/comment.dart';
import '../models/category.dart';

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

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
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
        postedAt TEXT,
        sellerId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER,
        username TEXT,
        content TEXT,
        createdAt TEXT,
        rating REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT,
        description TEXT,
        count INTEGER
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE car_listings ADD COLUMN sellerId TEXT');
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS comments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER,
          username TEXT,
          content TEXT,
          createdAt TEXT,
          rating REAL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id INTEGER PRIMARY KEY,
          name TEXT,
          description TEXT,
          count INTEGER
        )
      ''');
    }
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

  Future<int> insertComment(Comment comment) async {
    final db = await instance.database;
    return await db.insert('comments', comment.toMap());
  }

  Future<List<Comment>> getComments(int productId) async {
    final db = await instance.database;
    final result = await db.query(
      'comments',
      where: 'productId = ?',
      whereArgs: [productId],
      orderBy: 'createdAt DESC',
    );
    return result.map((json) => Comment.fromMap(json)).toList();
  }

  Future<int> insertCategory(Category category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((json) => Category.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
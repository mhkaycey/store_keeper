import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:store_keeper/model/product_model.dart';

class ProductServices {
  static final ProductServices _instance = ProductServices._init();
  ProductServices._init();
  static Database? _db;
  factory ProductServices() => _instance;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'store_inventory.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id TEXT PRIMARY KEY,
            name TEXT,
            price REAL,
            quantity INTEGER,
            category TEXT,
            imagePath TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  Future<void> addProduct(Product product) async {
    final db = await database;
    await db.insert(
      'products',
      product.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
  }

  Future<Product?> getSingleProduct(String id) async {
    final db = await database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return Product.fromJson(result.first);
    return null;
  }

  Future<List<Product>> searchProduct(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'products',
      where: 'LOWER(name) LIKE ?',
      whereArgs: ['%${query.toLowerCase()}%'],
    );
    return result.map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> filterProduct(String category) async {
    final db = await database;
    if (category == 'all') return getAllProducts();
    final result = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
    );
    return result.map((e) => Product.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;

    final totalProducts =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM products'),
        ) ??
        0;

    final totalValue = await db.rawQuery(
      'SELECT SUM(price * quantity) as total FROM products',
    );

    final totalQuantity =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT SUM(quantity) FROM products'),
        ) ??
        0;

    return {
      'totalProducts': totalProducts,
      'totalValue': (totalValue.first['total'] as num?)?.toDouble() ?? 0.0,
      'totalQuantity': totalQuantity,
    };
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

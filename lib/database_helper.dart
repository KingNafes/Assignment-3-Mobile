import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'food_ordering.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE food_items(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, cost REAL)',
        );
        await db.execute(
          'CREATE TABLE orders(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, target_cost REAL, food_item_ids TEXT)',
        );

        // Insert initial 20 food items
        for (int i = 1; i <= 20; i++) {
          await db.insert(
            'food_items',
            {'name': 'Food $i', 'cost': i * 1.5},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      },
    );
  }

  // Insert a new food item
  Future<void> insertFoodItem(String name, double cost) async {
    final db = await database;
    await db.insert(
      'food_items',
      {'name': name, 'cost': cost},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all food items
  Future<List<Map<String, dynamic>>> getFoodItems() async {
    final db = await database;
    return await db.query('food_items');
  }

  // Get food items under target cost
  Future<List<Map<String, dynamic>>> getFoodItemsUnderCost(double targetCost) async {
    final db = await database;
    return await db.query('food_items', where: 'cost <= ?', whereArgs: [targetCost]);
  }

  // Save an order
  Future<void> saveOrder(String date, double targetCost, List<int> foodItemIds) async {
    final db = await database;
    await db.insert(
      'orders',
      {
        'date': date,
        'target_cost': targetCost,
        'food_item_ids': foodItemIds.join(','),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Query order plans by date
  Future<List<Map<String, dynamic>>> getOrderPlans(String date) async {
    final db = await database;
    return await db.query('orders', where: 'date = ?', whereArgs: [date]);
  }

  // Update food item
  Future<void> updateFoodItem(int id, String name, double cost) async {
    final db = await database;
    await db.update(
      'food_items',
      {'name': name, 'cost': cost},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete food item
  Future<void> deleteFoodItem(int id) async {
    final db = await database;
    await db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }
}

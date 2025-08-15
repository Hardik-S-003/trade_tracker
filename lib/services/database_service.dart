import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/trade.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'trades.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE trades(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cryptoAsset TEXT NOT NULL,
        tradeType TEXT NOT NULL,
        amount REAL NOT NULL,
        entryPrice REAL NOT NULL,
        exitPrice REAL,
        currency TEXT NOT NULL,
        date TEXT NOT NULL,
        rationale TEXT,
        imagePath TEXT,
        profitLoss REAL
      )
    ''');
  }

  Future<int> insertTrade(Trade trade) async {
    final db = await database;
    return await db.insert('trades', trade.toMap());
  }

  Future<List<Trade>> getAllTrades() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trades',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Trade.fromMap(maps[i]);
    });
  }

  Future<Trade?> getTrade(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trades',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Trade.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTrade(Trade trade) async {
    final db = await database;
    return await db.update(
      'trades',
      trade.toMap(),
      where: 'id = ?',
      whereArgs: [trade.id],
    );
  }

  Future<int> deleteTrade(int id) async {
    final db = await database;
    return await db.delete(
      'trades',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Trade>> getTradesByAsset(String asset) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trades',
      where: 'cryptoAsset = ?',
      whereArgs: [asset],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Trade.fromMap(maps[i]);
    });
  }

  Future<List<Trade>> getTradesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trades',
      where: 'tradeType = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Trade.fromMap(maps[i]);
    });
  }

  Future<List<Trade>> getTradesInDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trades',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Trade.fromMap(maps[i]);
    });
  }

  Future<void> clearAllTrades() async {
    final db = await database;
    await db.delete('trades');
  }
}
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "CardOrganizer.db";
  static const _databaseVersion = 1;

  static const folderTable = 'folders';
  static const cardTable = 'cards';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnTimestamp = 'timestamp';
  static const columnSuit = 'suit';
  static const columnImageUrl = 'imageUrl';
  static const columnFolderId = 'folderId';

  late Database _db;

  static var instance;

  // this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $folderTable (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnName TEXT NOT NULL,
      $columnTimestamp TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE $cardTable (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnName TEXT NOT NULL,
      $columnSuit TEXT NOT NULL,
      $columnImageUrl TEXT NOT NULL,
      $columnFolderId INTEGER,
      FOREIGN KEY ($columnFolderId) REFERENCES $folderTable ($columnId)
    )
    ''');

    await _prepopulateCards(db);
  }

  Future _prepopulateCards(Database db) async {
    final suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    final cardNames = [
      'Ace',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'Jack',
      'Queen',
      'King'
    ];

    for (var suit in suits) {
      for (var cardName in cardNames) {
        await db.insert(cardTable, {
          'name': '$cardName of $suit',
          'suit': suit,
          'imageUrl': 'assets/images/${cardName}_of_${suit}.png',
        });
      }
    }
  }

  // Helper methods
  Future<int> insert(String table, Map<String, dynamic> row) async {
    return await _db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    return await _db.query(table);
  }

  Future<int> queryRowCount(String table) async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> update(String table, Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String table, int id) async {
    return await _db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Folder CRUD operations
  Future<int> insertFolder(Map<String, dynamic> row) async {
    row[columnTimestamp] = DateTime.now().toIso8601String();
    return await insert(folderTable, row);
  }

  Future<int> updateFolder(Map<String, dynamic> row) async {
    return await update(folderTable, row);
  }

  Future<int> deleteFolder(int id) async {
    // Delete all cards in the folder first
    await _db.delete(
      cardTable,
      where: '$columnFolderId = ?',
      whereArgs: [id],
    );
    // Then delete the folder
    return await delete(folderTable, id);
  }

  // Card CRUD operations
  Future<int> insertCard(Map<String, dynamic> row) async {
    return await insert(cardTable, row);
  }

  Future<int> updateCard(Map<String, dynamic> row) async {
    return await update(cardTable, row);
  }

  Future<int> deleteCard(int id) async {
    return await delete(cardTable, id);
  }
}
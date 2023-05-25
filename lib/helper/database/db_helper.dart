import 'package:path/path.dart' as Path;
import 'package:prohelp_app/model/search/search_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {
  String dbName = "transactions_database.db";

  Future<Database> initDB() async {
    return await openDatabase(
      Path.join(await getDatabasesPath(), dbName),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE RecentSearches(id INTEGER PRIMARY KEY, name TEXT, created_at TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> saveSearch(SearchModel searches) async {
    int result = 0;
    final Database db = await initDB();
    final id = await db.insert('RecentSearches', searches.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<SearchModel>> recentSearches() async {
    // Get a reference to the database.
    final db = await initDB();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
        await db.query('RecentSearches', orderBy: "created_at");

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return SearchModel(
        id: maps[i]['id'],
        key: maps[i]['name'],
        createdAt: maps[i]['created_at'],
      );
    });
  }

  Future<void> updateTransaction(SearchModel searchModel) async {
    // Get a reference to the database.
    final db = await initDB();

    // Update the given Transaction.
    await db.update(
      'RecentSearches',
      searchModel.toMap(),
      // Ensure that the Transaction has a matching id.
      where: 'id = ?',
      // Pass the Transaction's id as a whereArg to prevent SQL injection.
      whereArgs: [searchModel.id],
    );
  }
}

import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<sql.Database> getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'places.db'),
      version: 1,
      onCreate: (db, _) {
        return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, loc_lat REAL, loc_lng REAL)',
        );
      },
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final sqlDb = await DBHelper.getDatabase();
    await sqlDb.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, Object>>> getData(table) async {
    final sqlDb = await DBHelper.getDatabase();
    return sqlDb.query(table);
  }
}

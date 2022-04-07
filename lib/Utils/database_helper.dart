import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "valocompanion.db";
  static const _databaseVersion = 1;

  static const usersTable = 'users';

  static const columnId = 'id';
  static const columnUsername = 'username';
  static const columnPassword = 'password';
  static const columnRegion = 'region';
  static const columnDisplayName = 'display_name';
  static const columnSubject = 'subject';
  static const columnGameName = 'game_name';
  static const columnTagline = 'tagLine';
  static const columnPlayerCard = 'playerCard';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    sqfliteFfiInit();
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    var databaseFactory = databaseFactoryFfi;
    String path = join(documentsDirectory.path, _databaseName);
    if (Platform.isAndroid || Platform.isIOS) {
      return await openDatabase(path,
          version: _databaseVersion, onCreate: _onCreate);
    }
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
      ),
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $usersTable (
            $columnId INTEGER PRIMARY KEY,
            $columnUsername TEXT NOT NULL,
            $columnPassword TEXT NOT NULL,
            $columnRegion TEXT NOT NULL,
            $columnDisplayName TEXT NOT NULL,
            $columnSubject TEXT NOT NULL,
            $columnGameName TEXT NOT NULL,
            $columnTagline TEXT NOT NULL,
            $columnPlayerCard TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(usersTable, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(usersTable);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $usersTable'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db
        .update(usersTable, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(usersTable, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(usersTable);
  }
}

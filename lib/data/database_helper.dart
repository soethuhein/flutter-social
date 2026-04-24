import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

typedef DbPathResolver = Future<String> Function();

class DatabaseHelper {
  DatabaseHelper({
    DatabaseFactory? databaseFactory,
    DbPathResolver? dbPathResolver,
  })  : _databaseFactory = databaseFactory,
        _dbPathResolver = dbPathResolver ?? getDatabasesPath;

  final DatabaseFactory? _databaseFactory;
  final DbPathResolver _dbPathResolver;

  Database? _database;

  Future<Database> database() async {
    if (_database != null) {
      return _database!;
    }

    final String basePath = await _dbPathResolver();
    final String path = basePath == inMemoryDatabasePath
        ? inMemoryDatabasePath
        : join(basePath, 'messages.db');

    if (_databaseFactory != null) {
      _database = await _databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
      return _database!;
    }

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return _database!;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        image_path TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }
}

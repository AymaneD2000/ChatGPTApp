import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._();
  static Database? _database;

  DatabaseManager._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'conversation_sessions.db');
    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE IF NOT EXISTS sessions (
            id INTEGER PRIMARY KEY,
            userMessage TEXT,
            aiReply TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveSession(List<String> session) async {
    final db = await database;
    for (int i = 0; i < session.length; i += 2) {
      final userMessage = session[i];
      final aiReply = session[i + 1];
      await db.insert(
        'sessions',
        {'userMessage': userMessage, 'aiReply': aiReply},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<List<String>>> getAllSessions() async {
    final db = await database;
    final sessions = await db.query('sessions');
    final sessionList = <List<String>>[];
    for (final session in sessions) {
      final userMessage = session['userMessage'] as String;
      final aiReply = session['aiReply'] as String;
      sessionList.add([userMessage, aiReply]);
    }
    return sessionList;
  }
}

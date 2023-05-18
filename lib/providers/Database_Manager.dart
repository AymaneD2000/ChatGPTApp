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

  Future<void> createGlobalsessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Globalsessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionName TEXT NOT NULL
      )
    ''');
  }

  Future<void> createSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sessions (
        id INTEGER PRIMARY KEY,
        userMessage TEXT,
        aiReply TEXT,
        session_id INTEGER,
        FOREIGN KEY (session_id) REFERENCES Globalsessions(id)
      )
    ''');
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'conversation_sessions.db');
    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await createGlobalsessionsTable(db);
        await createSessionsTable(db);
      },
    );
  }

  Future<void> saveSession(List<String> session, int globalId) async {
    final db = await database;
    for (int i = 0; i < session.length; i += 2) {
      final userMessage = session[i];
      final aiReply = session[i + 1];
      await db.insert(
        'sessions',
        {
          'userMessage': userMessage,
          'aiReply': aiReply,
          'session_id': globalId
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<int> saveGlobalSession(String sessionName) async {
    final db = await database;
    final id = await db.insert(
      'Globalsessions',
      {'sessionName': sessionName},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> updateGlobalSession(int globalId, String sessionName) async {
    final db = await database;
    await db.update(
      'Globalsessions',
      {'sessionName': sessionName},
      where: 'id = ?',
      whereArgs: [globalId],
    );
  }

  Future<List<List<String>>> getAllSessions() async {
    final db = await database;
    final sessions = await db.query('sessions');
    final sessionList = <List<String>>[];
    for (final session in sessions) {
      final userMessage = session['userMessage'] as String;
      final aiReply = session['aiReply'] as String;
      final sessionId = session['session_id'].toString();
      sessionList.add([userMessage, aiReply, sessionId]);
    }
    return sessionList;
  }

  Future<List<Map<String, dynamic>>> getAllGlobalSessions() async {
    final db = await database;
    return await db.query('Globalsessions');
  }
}

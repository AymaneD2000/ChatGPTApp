import 'package:gpt_flutter/models/Discussion.dart';
import 'package:gpt_flutter/models/Session.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/discussion_list_model.dart';

class DatabaseManager {
  int _index = 0;
  int get index => _index;
  static final DatabaseManager instance = DatabaseManager._();
  static Database? _database;

  DatabaseManager._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static const String global = "Globalsessions";
  static const String sessionsTable = "sessions";
  static const String sessionsListeTable = "sessionsListe";

  Future<void> createGlobalsessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $global (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionName TEXT NOT NULL
      )
    ''');
  }

  Future<void> createSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $sessionsTable (
        id INTEGER PRIMARY KEY,
        userMessage TEXT,
        aiReply TEXT,
        session_id INTEGER,
        FOREIGN KEY (session_id) REFERENCES Globalsessions(id)
      )
    ''');
  }

  Future<void> createSessionsListe(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $sessionsListeTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list TEXT,
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
        await createSessionsListe(db);
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

//enregistrer une liste de conversation
  Future<int> saveSessionListe(String liste, int sessionID) async {
    final db = await database;
    return await db
        .insert(sessionsListeTable, {"list": liste, "session_id": sessionID});
  }

  //Suppression de liste de session
  Future<void> deleteSessionListe(int sid) async {
    final db = await database;
    try {
      final id = await db
          .delete(sessionsListeTable, where: 'session_id=?', whereArgs: [sid]);
      print("liste Supprimer avec succes");
    } catch (e) {
      print("Erreur lors de la suppression de  GlobalSession");

      print(e);
    }
  }

  //mise a jour  de liste de session
  Future<void> updateSessionListe(String newListe, int sid) async {
    final db = await database;
    try {
      final id = await db.update(sessionsListeTable, {"list": newListe},
          where: 'session_id=?', whereArgs: [sid]);
      print("liste Supprimer avec succes");
    } catch (e) {
      print("Erreur lors de la suppression de  GlobalSession");

      print(e);
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

//Suppression de session global
  Future<void> deleteGlobalSession(int sid) async {
    final db = await database;
    try {
      final id = await db.delete(global, where: 'id=?', whereArgs: [sid]);
      print("Supprimer avec succes");
    } catch (e) {
      print("Erreur lors de la suppression de  GlobalSession");

      print(e);
    }
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

//recuperer la liste de conversation pour un une session globale
  Future<List<DiscussionList>> getAllSessionsListe(int id) async {
    final db = await database;
    final sessions = await db
        .query(sessionsListeTable, where: 'session_id=?', whereArgs: [id]);
    final listSession = <DiscussionList>[];
    //final List<String> sessionList = [];

    for (final session in sessions) {
      final temp = DiscussionList.fromMap(session);
      temp.discussions = await getSessionForGlobal(id);
      // final liste = session['list'] as String;
      // sessionList.add(liste);
      // print("getAllSessionsListe $liste");
      //sessionList.add([userMessage, aiReply, sessionId]);
    }
    return listSession;
  }

  Future<List<Discussion>> getAllSessions() async {
    final db = await database;
    final sessions = await db.query('sessions');
    final ListSession = <Discussion>[];
    //final sessionList = <List<String>>[];
    for (final session in sessions) {
      ListSession.add(Discussion.fromMap(session));
      // final userMessage = session['userMessage'] as String;
      // final aiReply = session['aiReply'] as String;
      // final sessionId = session['session_id'].toString();
      // sessionList.add([userMessage, aiReply, sessionId]);
    }
    return ListSession;
  }

  Future<List<Discussion>> getSessionForGlobal(int id) async {
    final db = await database;
    final sessions =
        await db.query(sessionsTable, where: 'session_id=?', whereArgs: [id]);
    final sessionList = <Discussion>[];
    // int i = 0;
    for (final session in sessions) {
      final temp = Discussion.fromMap(session);
      // final userMessage = session['userMessage'] as String;
      // final aiReply = session['aiReply'] as String;
      // final sessionId = session['session_id'].toString();
      // final sessionI = session['session_id'] as int;
      // i = sessionI;
      sessionList.add(temp);
    }

    return sessionList;
  }

  Future<List<Session>> getAllGlobalSessions() async {
    final db = await database;
    final list = await db.query('Globalsessions');
    final sessionList = <Session>[];
    for (final session in list) {
      final temp = Session.fromMap(session);
      temp.discussions = await getSessionForGlobal(temp.id);
      sessionList.add(temp);
    }
    return sessionList;
  }
}

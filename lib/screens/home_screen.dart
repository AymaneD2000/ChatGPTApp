import 'package:flutter/material.dart';
import 'package:gpt_flutter/screens/chat_screen.dart';

import '../models/Session.dart';
import '../providers/Database_Manager.dart';
import '../services/ai_handler.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AIHandler aiHandler = AIHandler();
  final DatabaseManager _databaseManager = DatabaseManager.instance;
  late Future<List<List<String>>> conversationSessionsFuture;
  late Future<List<Map<String, dynamic>>> globalSessionsFuture;

  void _openSession() async {
    if (!aiHandler.isSessionOpen) {
      aiHandler.openSession();
    }
    int id = await _databaseManager.saveGlobalSession('sessionName');
    Session session = Session(id: id, name: 'sessionName');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => ChatScreen(sessionId: session.id)),
    ).then((value) {
      if (!aiHandler.isSessionOpen) {
        aiHandler.openSession();
      }
    });
  }

  void _reconnectToSession(List<List<String>> session, int id) {
    aiHandler.openSession();
    session.forEach((message) async {
      await Future.delayed(Duration(
          milliseconds:
              500)); // Attendre un court laps de temps entre chaque message
      await aiHandler.getResponse(message.first, id);
    });
  }

  @override
  void initState() {
    super.initState();
    conversationSessionsFuture = aiHandler.getConversationSessions();
    globalSessionsFuture = _databaseManager.getAllGlobalSessions();
  }

  void _closeSession() {
    aiHandler.closeSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: FutureBuilder<List<List<String>>>(
        future: conversationSessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Une erreur s\'est produite.'),
            );
          } else if (snapshot.hasData) {
            final conversationSessions = snapshot.data!;
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: globalSessionsFuture,
              builder: (context, globalSnapshot) {
                if (globalSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (globalSnapshot.hasError) {
                  return Center(
                    child: Text('Une erreur s\'est produite.'),
                  );
                } else if (globalSnapshot.hasData) {
                  final globalSessions = globalSnapshot.data!;
                  return ListView.builder(
                    itemCount: globalSessions.length,
                    itemBuilder: (context, index) {
                      final globalSession = globalSessions[index];
                      final globalSessionId = globalSession['id'] as int;
                      final globalSessionName =
                          globalSession['sessionName'] as String;
                      final sessionTitle =
                          'GlobalSession ${index + 1}: $globalSessionName';
                      final session = conversationSessions
                          .where((session) =>
                              session.last == globalSessionId.toString())
                          .toList();
                      final lastUserMessage = session.first.first;
                      final lastReply = session.first.last;

                      return Card(
                        child: ListTile(
                          title: Text(sessionTitle),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('User: $lastUserMessage'),
                              Text('AI Reply: $lastReply'),
                            ],
                          ),
                          onTap: () {
                            //Navigator.pushReplacement(context, newRoute)
                            _reconnectToSession(session, globalSessionId);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  sessionId: globalSessionId,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text('Aucune session de conversation trouvée.'),
                  );
                }
              },
            );
          } else {
            return Center(
              child: Text('Aucune session de conversation trouvée.'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openSession,
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    aiHandler.dispose();
    super.dispose();
  }
}

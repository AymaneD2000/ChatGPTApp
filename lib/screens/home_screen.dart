import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_flutter/models/Discussion.dart';
import 'package:gpt_flutter/screens/chat_screen.dart';
import 'package:gpt_flutter/screens/setting_screen.dart';
import 'package:gpt_flutter/widgets/home_app_bar.dart';

import '../models/Session.dart';
import '../providers/Database_Manager.dart';
import '../providers/active_theme_provider.dart';
import '../services/ai_handler.dart';
import '../widgets/drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AIHandler aiHandler = AIHandler();
  final DatabaseManager _databaseManager = DatabaseManager.instance;
  late Future<List<Session>> globalSessionsFuture;

  @override
  void initState() {
    super.initState();
    globalSessionsFuture = _databaseManager.getAllGlobalSessions();
  }

  void _openSession() async {
    int id = await _databaseManager.saveGlobalSession('sessionName');
    Session session = Session(id: id, name: 'sessionName');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          sessionId: session.id,
        ),
      ),
    );
  }

  void _reconnectToSession(List<Discussion> session, int id) async {
    aiHandler.openSession();
    for (var message in session) {
      await Future.delayed(Duration(milliseconds: 500));
      // await aiHandler.getResponse(message.userMessage, id);
    }
  }

  @override
  void dispose() {
    aiHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: HomeAppBar(),
      body: FutureBuilder<List<Session>>(
        future: globalSessionsFuture,
        builder: (context, globalSnapshot) {
          if (globalSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (globalSnapshot.hasError) {
            return Center(
              child: Text('An error occurred.'),
            );
          } else if (globalSnapshot.hasData) {
            final globalSessions = globalSnapshot.data!;
            return ListView.builder(
              itemCount: globalSessions.length,
              itemBuilder: (context, index) {
                final session = globalSessions[index];
                final discussions = session.discussions ?? [];
                final messageUser =
                    discussions.isNotEmpty ? discussions.first.userMessage : '';
                final messageIA =
                    discussions.isNotEmpty ? discussions.first.aiReply : '';
                return Card(
                  child: ListTile(
                    title: Text(session.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User: $messageUser'),
                        Text('AI Reply: $messageIA'),
                      ],
                    ),
                    onTap: () {
                      _reconnectToSession(discussions, session.id);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                list: discussions, sessionId: session.id)),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('No conversation sessions found.'),
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
}

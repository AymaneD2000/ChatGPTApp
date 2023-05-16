import 'package:flutter/material.dart';
import 'package:gpt_flutter/screens/chat_screen.dart';

import '../services/ai_handler.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
final AIHandler aiHandler = AIHandler();
  late Future<List<List<String>>> conversationSessionsFuture;

  void _openSession() {
  if (!aiHandler.isSessionOpen) {
    aiHandler.openSession();
  }
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ChatScreen()),
  ).then((value) {
    if (!aiHandler.isSessionOpen) {
      aiHandler.openSession();
    }
  });
}



  @override
void initState() {
  super.initState();
  conversationSessionsFuture = aiHandler.getConversationSessions();
}


  void _closeSession() {
    aiHandler.closeSession();
  }

  void _reconnectToSession(List<String> session) {
  aiHandler.openSession();
  session.forEach((message) async {
    await Future.delayed(Duration(milliseconds: 500)); // Attendre un court laps de temps entre chaque message
    await aiHandler.getResponse(message);
  });
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
          return ListView.builder(
            itemCount: conversationSessions.length,
            itemBuilder: (context, index) {
              final session = conversationSessions[index];
              final sessionTitle = 'Session ${index + 1}';
              final lastUserMessage = session.first;
              final lastReply = session.last;

              return ListTile(
                title: Text(sessionTitle),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User: $lastUserMessage'),
                    Text('AI Reply: $lastReply'),
                  ],
                ),
                onTap: () {
                  _reconnectToSession(session);
                  // Gérer la navigation ou toute autre action pour continuer la conversation
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen()));
                },
              );
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
    bottomNavigationBar: BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _closeSession,
          child: Text('Fermer la session'),
        ),
      ),
    ),
  );
}


  @override
  void dispose() {
    aiHandler.dispose();
    //super.dispose();
  }
}

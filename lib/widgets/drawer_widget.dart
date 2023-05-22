import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/Session.dart';
import '../providers/Database_Manager.dart';
import '../providers/active_theme_provider.dart';
import '../screens/chat_screen.dart';
import '../screens/setting_screen.dart';
import '../services/ai_handler.dart';

class DrawerWidget extends StatelessWidget {
  DrawerWidget({
    super.key,
  });
  final AIHandler aiHandler = AIHandler();
  final DatabaseManager _databaseManager = DatabaseManager.instance;
  late Future<List<Session>> globalSessionsFuture;

  @override
  Widget build(BuildContext context) {
    globalSessionsFuture = _databaseManager.getAllGlobalSessions();
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: const Text(
              "Your history",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Session>>(
              future: globalSessionsFuture,
              builder: (context, globalSnapshot) {
                if (globalSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (globalSnapshot.hasError) {
                  return const Center(
                    child: Text('An error occurred.'),
                  );
                } else if (globalSnapshot.hasData) {
                  final globalSessions = globalSnapshot.data!;
                  return ListView.builder(
                    itemCount: globalSessions.length,
                    itemBuilder: (context, index) {
                      final session = globalSessions[index];
                      final discussions = session.discussions ?? [];
                      final messageUser = discussions.isNotEmpty
                          ? discussions.first.userMessage
                          : '';
                      final messageIA = discussions.isNotEmpty
                          ? discussions.first.aiReply
                          : '';
                      return Card(
                          child: ListTile(
                        isThreeLine: true,
                        title: Text(
                          messageUser.length > 20
                              ? messageUser.substring(0, 20) +
                                  '...' // Add ellipsis if text is too long
                              : messageUser,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          messageIA.length > 50
                              ? messageIA.substring(0, 50) +
                                  '...' // Add ellipsis if text is too long
                              : messageIA,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                list: discussions,
                                sessionId: session.id,
                              ),
                            ),
                          );
                        },
                      ));
                    },
                  );
                } else {
                  return Center(
                    child: Text('No conversation sessions found.'),
                  );
                }
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: TextButton(
              child: Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return const Setting();
                        }));
                      },
                      child: Row(
                        children: [
                          Consumer(
                              builder: (context, ref, child) => IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.settings,
                                    color: ref.watch(activeThemeProvider) ==
                                            Themes.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ))),
                          Consumer(
                              builder: (context, ref, child) => Text(
                                    "Settings",
                                    style: TextStyle(
                                        color: ref.watch(activeThemeProvider) ==
                                                Themes.dark
                                            ? Colors.white
                                            : Colors.black),
                                  )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}

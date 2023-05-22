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
//import '../widgets/Expande_tile_topic.dart';
//import '../widgets/Profile_container.dart';
import '../widgets/Topics_Suggestion_List.dart';
//import '../widgets/Topics_liste.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/expand_tile_topic.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AIHandler aiHandler = AIHandler();
  final DatabaseManager _databaseManager = DatabaseManager.instance;

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
      body: Consumer(builder: (context, ref, child) {
        final theme = ref.watch(activeThemeProvider);
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "I suggest you some topics you can ask me",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme == Themes.dark ? Colors.black : Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DiscussionsExpansionTile(
                          discussions: topics[index],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final theme = ref.watch(activeThemeProvider);

          return FloatingActionButton(
            onPressed: _openSession,
            backgroundColor: theme == Themes.dark ? Colors.white : Colors.black,
            foregroundColor: theme == Themes.dark ? Colors.black : Colors.white,
            child: Icon(Icons.message),
          );
        },
      ),
    );
  }
}

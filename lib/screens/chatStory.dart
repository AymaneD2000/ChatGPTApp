import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_flutter/models/Discussion.dart';

import '../models/Session.dart';
import '../providers/Database_Manager.dart';
import '../services/ai_handler.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ChatStory extends StatefulWidget {
  const ChatStory({Key? key});

  @override
  State<ChatStory> createState() => _ChatStoryState();
}

class _ChatStoryState extends State<ChatStory> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AIHandler aiHandler = AIHandler();
  final DatabaseManager _databaseManager = DatabaseManager.instance;
  late Future<List<Session>> globalSessionsFuture;
  TextEditingController textControle = TextEditingController();

  double keyboardHeight = 0;

  void adjustContentPosition(bool isKeyboardVisible) {
    if (isKeyboardVisible) {
      setState(() {
        keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      });
    } else {
      setState(() {
        keyboardHeight = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    globalSessionsFuture = _databaseManager.getAllGlobalSessions();
  }

  Future<void> delete(int sid) async {
    print("Suppression en cours...");
    await _databaseManager.deleteGlobalSession(sid);
    print("Supprimé");
  }

  Future<void> changeName(int sid, String text) async {
    print("Suppression en cours...");
    await _databaseManager.updateGlobalSession(sid, text);
    print("Supprimé");
  }

  Future<void> deleteDialog(int toDelete) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Attention !"),
          content: const Text(
              "Êtes-vous sûr de vouloir supprimer cette session de l'historique ?"),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    delete(toDelete).then((value) async {
                      var result = _databaseManager.getAllGlobalSessions();
                      setState(() {
                        globalSessionsFuture = result;
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancele",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.black38,
        title: Row(
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: const Icon(Icons.arrow_back_ios)),
            const Spacer(),
            const Text("History"),
            const Spacer()
          ],
        ),
      ),
      body: Container(
        color: Colors.black38,
        child: FutureBuilder<List<Session>>(
          future: globalSessionsFuture,
          builder: (context, globalSnapshot) {
            if (globalSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (globalSnapshot.hasError) {
              return const Center(
                child: Text('Erreur.'),
              );
            } else if (globalSnapshot.hasData) {
              final globalSessions = globalSnapshot.data!;

              if (globalSessions.isEmpty) {
                return const Center(
                  child: Text('No conversation found'),
                );
              }

              return SizedBox(
                width: double.infinity,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: globalSessions.length,
                  itemBuilder: (context, index) {
                    final session = globalSessions[index];
                    final discussions = session.discussions ?? [];
                    final messageUser = discussions.isNotEmpty
                        ? discussions.first.userMessage
                        : "";
                    final messageIA =
                        discussions.isNotEmpty ? discussions.first.aiReply : '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              sessionId: session.id,
                              list: session.discussions,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () => showModalBottomSheet(
                                      context: context,
                                      builder: (ctx) => _buildBottomSheet(
                                          context, session.id)),
                                  child: const Icon(
                                    Icons.more_horiz,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 5),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                              child: Text(
                                session.name.length > 30
                                    ? '${session.name.substring(0, 20)}...'
                                    : session.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              decoration: BoxDecoration(
                                color: Colors.lightGreen.shade900,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.greenAccent),
                              ),
                              child: Text(
                                messageIA.length > 50
                                    ? '${messageIA.substring(0, 40)}...'
                                    : messageIA,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return const Center(
                child: Text('Aucune conversation trouvée'),
              );
            }
          },
        ),
      ),
    );
  }

  Container _buildBottomSheet(BuildContext context, int id) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.transparent,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: const Text(
              "Choose action",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          GestureDetector(
            onTap: () {
              showBottomSheet(
                  context: context,
                  builder: (context) => _renameStory(context, id));
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8.0),
                  GestureDetector(
                    child: const Text(
                      "Rename",
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () => deleteDialog(id),
            child: Container(
              padding: const EdgeInsets.all(15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: const [
                  Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    "Delete",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _renameStory(BuildContext context, int id) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: const Text(
              "Rename",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Write new name',
                border: InputBorder
                    .none, // Ajout de cette ligne pour enlever le trait vertical
              ),
              controller: textControle,
            ),
          ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () async {
              await changeName(id, textControle.text);
              var result = _databaseManager.getAllGlobalSessions();
              setState(() {
                globalSessionsFuture = result;
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Confirm",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

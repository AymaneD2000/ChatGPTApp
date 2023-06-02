// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:gpt_flutter/screens/chat_screen.dart';

import 'package:gpt_flutter/widgets/home_app_bar.dart';
import '../models/Session.dart';
import '../providers/Database_Manager.dart';

import '../services/ai_handler.dart';

import '../widgets/topics_suggestion_list.dart';
import 'chatStory.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AIHandler aiHandler = AIHandler();
  final DatabaseManager _databaseManager = DatabaseManager.instance;
  late Future<List<Session>> globalSessionsFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    aiHandler.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  Future<void> delete(int sid) async {
    print("deleting ...");
    await _databaseManager.deleteGlobalSession(sid);
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
                    "Supprimer",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Annuler",
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

  Container _buildBottomSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black38,
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onTap: _openSession,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'write your message here',
                border: InputBorder.none, // Supprime la ligne du TextField
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // Action lorsqu'on appuie sur l'icône d'envoi
            },
          ),
        ],
      ),
    );
  }

  int selectIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: _buildBottomSheet(context),
      backgroundColor: Colors.white10,
      appBar: const HomeAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  "My History",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => ChatStory()));
                  },
                  child: const Text(
                    "See all",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Session>>(
              future: globalSessionsFuture,
              builder: (context, globalSnapshot) {
                if (globalSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (globalSnapshot.hasError) {
                  return const Center(
                    child: Text('Error.'),
                  );
                } else if (globalSnapshot.hasData) {
                  final globalSessions = globalSnapshot.data!;
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.16,
                    width: double.infinity,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: globalSessions.length,
                      itemBuilder: (context, index) {
                        final session = globalSessions[index];
                        final discussions = session.discussions ?? [];
                        final messageIA = discussions.isNotEmpty
                            ? discussions.first.aiReply
                            : '';

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                          sessionId: session.id,
                                          list: session.discussions,
                                        )));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 15),
                            width: MediaQuery.of(context).size.width * 0.7,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    session.name.length > 30
                                        ? '${session.name.substring(0, 20)}...' // Ajoute des points de suspension si le texte est trop long
                                        : session.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Text(
                                  "See your recent conversation",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
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
                    child: Text('No conversation found'),
                  );
                }
              },
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.topLeft,
              child: const Text(
                "Suggestions",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectIndex = index;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 15),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selectIndex == index
                            ? Colors.blue
                            : Colors
                                .white10, // Change la couleur du conteneur si c'est la sélection actuelle
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(topics[index].icon),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            topics[index].topic,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.45, // Ajustez la hauteur de la ListView selon vos besoins
              child: ListView.builder(
                controller: _scrollController,
                itemCount: topics[selectIndex].suggestions.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      int id = await _databaseManager
                          .saveGlobalSession('sessionName');
                      Session session = Session(id: id, name: 'sessionName');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            sessionId: session.id,
                            messageTopics: topics[selectIndex]
                                .suggestions[index]
                                .suggestionPrompt,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white12,
                      ),
                      child: Text(
                        topics[selectIndex].suggestions[index].suggestions,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

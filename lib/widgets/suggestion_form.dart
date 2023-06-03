import 'package:flutter/material.dart';

import '../models/Session.dart';
import '../providers/Database_Manager.dart';
import '../screens/chat_screen.dart';
import 'Topics_Suggestion_List.dart';

class SuggestionForm extends StatefulWidget {
  const SuggestionForm({super.key});

  @override
  State<SuggestionForm> createState() => _SuggestionFormState();
}

class _SuggestionFormState extends State<SuggestionForm> {
  DatabaseManager _databaseManager = DatabaseManager.instance;
  final ScrollController _scrollController = ScrollController();
  int selectIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          border: Border.all(width: 2)),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(0, 15, 0, 5),
                  child: const Text(
                    "Suggestion",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    scrollDirection: Axis.horizontal,
                    itemCount: topics.length,
                    itemBuilder: (cont, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectIndex = index;
                            print(selectIndex);
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
                          child: GestureDetector(
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
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.7, // Ajustez la hauteur de la ListView selon vos besoins
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: topics[selectIndex].suggestions.length,
                    itemBuilder: (cont, index) {
                      return GestureDetector(
                        onTap: () async {
                          int id = await _databaseManager
                              .saveGlobalSession('sessionName');
                          Session session =
                              Session(id: id, name: 'sessionName');
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (cont) => ChatScreen(
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
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

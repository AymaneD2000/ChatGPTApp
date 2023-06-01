// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gpt_flutter/models/Discussion.dart';
import 'package:gpt_flutter/models/chat_model.dart';
import '../models/Session.dart';
import '../providers/Database_Manager.dart';
import '../providers/chats_provider.dart';
import '../services/ai_handler.dart';
import '../services/session_name.dart';
import '../widgets/Topics_Suggestion_List.dart';
import '../widgets/chat_item.dart';

import '../widgets/my_app_bar.dart';
import '../widgets/text_and_voice_field.dart';
import 'home_screen.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(
      {Key? key, this.messageTopics, required this.sessionId, this.list});
  static const String id = 'chat';
  final List<Discussion>? list;
  final int sessionId;
  final String? messageTopics;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isSpeacking = false;
  DatabaseManager _databaseManager = DatabaseManager.instance;
  late FlutterTts text_to_speech;
  Future _speack(String texte) async {
    await text_to_speech.setLanguage('en-US');
    await text_to_speech.setPitch(1.0);
    await text_to_speech.speak(texte);
  }

  Future stop() async {
    await text_to_speech.stop();
  }

  void _closeSession() {
    aiHandler.closeSession();
  }

  final AIHandler aiHandler = AIHandler();
  final List<ChatModel> list = [];
  int giveList = 0;
  String currentMessage = '';
  List<Map<String, String>> lastChat = [];

  @override
  void dispose() {
    aiHandler.closeSession();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    text_to_speech = FlutterTts();
    if (widget.list != null && widget.list!.isNotEmpty) {
      for (final element in widget.list!) {
        list.add(ChatModel(
          id: element.id.toString(),
          message: element.userMessage,
          isMe: true,
        ));
        list.add(ChatModel(
          id: element.id.toString(),
          message: element.aiReply,
          isMe: false,
        ));
        currentMessage = element.aiReply;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = DatabaseManager.instance;
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Consumer(builder: (context, ref, child) {
              final chats = ref.read(chatsProvider.notifier);
              chats.removeTyping();
              return GestureDetector(
                child: const Icon(
                  Icons.close,
                ),
                onTap: () async {
                  final chats = ref.read(chatsProvider.notifier);
                  chats.clean();

                  final result = await db.getSessionForGlobal(widget.sessionId);
                  final number = result.length;

                  if (number == 0) {
                    try {
                      await db.deleteGlobalSession(widget.sessionId);
                    } catch (e) {
                      print(e);
                    }
                  } else {
                    SessionName name = SessionName();
                    String title = await name.getResponse(
                        "give a expert title cool ans short for this tense tense :${result.first.userMessage}");
                    db.updateGlobalSession(widget.sessionId, title.toString());
                  }
                  _closeSession;
                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                },
              );
            }),
            const Spacer(),
            Text(
              'Zetron - AI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () async {
                  await stop();
                  setState(() {
                    isSpeacking = !isSpeacking;
                    print(isSpeacking);
                  });
                  if (isSpeacking) {
                    _speack(currentMessage).then((value) {
                      setState(() {
                        isSpeacking = false;
                      });
                    });
                  } else {
                    await stop();
                    setState(() {
                      isSpeacking = false;
                    });
                  }
                  print(isSpeacking);
                },
                icon: const Icon(Icons.volume_up)),
          ],
        ),
        actions: [
          Row(
            children: [],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer(builder: (context, ref, child) {
              final chats = ref.watch(chatsProvider).reversed.toList();
              List<ChatModel> thisListe = [];
              thisListe.addAll(list);
              //print(list.first.message);
              if (list != null && list != []) {
                if (giveList == 0) {
                  giveList += 1;
                  List<Map<String, String>> myList = [];
                  for (int i = 0; i < thisListe.length; i++) {
                    if (thisListe[i].isMe) {
                      myList.add(
                          {"role": "user", "content": thisListe[i].message});
                      print(thisListe[i].message);
                    } else {
                      myList.add({
                        "role": "assistant",
                        "content": thisListe[i].message
                      });
                    }
                  }
                  lastChat.addAll(myList);

                  print("Last chat a pour taille ${lastChat.length}");
                  //aiHandler.getResponse(myList, "message", widget.sessionId);
                }

                chats.addAll(list.reversed);
                if (chats.isNotEmpty) {
                  if (chats.last.isMe == false) {
                    currentMessage = chats.last.message;
                  }
                }
              }
              return chats.isEmpty
                  ? firdtMessage(
                      "Hi! You can send your message or get inspired from suggestion.")
                  : ListView.builder(
                      reverse: true,
                      itemCount: chats.length,
                      itemBuilder: (context, index) => ChatItem(
                        text: chats[index].message,
                        isMe: chats[index].isMe,
                      ),
                    );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextAndVoiceField(
              lastChat,
              id: widget.sessionId,
              message: widget.messageTopics,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget firdtMessage(String message) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: const BoxDecoration(color: Color.fromARGB(255, 40, 54, 40)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const ProfileContainer(isMe: false),
              //const SizedBox(width: 15),
              Container(
                //padding: const EdgeInsets.all(15),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                ),
                child: Column(
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 18),
                    ),
                    Container(
                      child: TextButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (con) => _buildBottomSheet(con));
                          },
                          icon: Icon(Icons.sms_failed),
                          label: Text("Suggestion")),
                    )
                  ],
                ),
              ),
              // if (widget.isMe) const SizedBox(width: 15),
              // if (widget.isMe) ProfileContainer(isMe: widget.isMe),
            ],
          ),
        ],
      ),
    );
  }

  Container _buildBottomSheet(BuildContext cont) {
    final ScrollController _scrollController = ScrollController();
    int selectIndex = 0;
    return Container(
      height: MediaQuery.of(cont).size.height * 0.7,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListView(
        children: <Widget>[
          const Text(
            "Suggestion",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topics.length,
              itemBuilder: (cont, index) {
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
            height: MediaQuery.of(cont).size.height *
                0.7, // Ajustez la hauteur de la ListView selon vos besoins
            child: ListView.builder(
              controller: _scrollController,
              itemCount: topics[selectIndex].suggestions.length,
              itemBuilder: (cont, index) {
                return GestureDetector(
                  onTap: () async {
                    int id =
                        await _databaseManager.saveGlobalSession('sessionName');
                    Session session = Session(id: id, name: 'sessionName');
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
      ),
    );
  }
}

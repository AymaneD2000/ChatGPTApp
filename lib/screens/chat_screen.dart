// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gpt_flutter/models/Discussion.dart';
import 'package:gpt_flutter/models/chat_model.dart';
import 'package:gpt_flutter/widgets/suggestion_form.dart';
import '../providers/Database_Manager.dart';
import '../providers/chats_provider.dart';
import '../services/ai_handler.dart';
import '../services/session_name.dart';
import '../widgets/chat_item.dart';

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
  GlobalKey _containerKey = GlobalKey();
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
      bottomSheet: _buildBottomSheet(context),
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white10,
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
                        "give a simple title cool and short for this tense tense :${result.first.userMessage}");
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
      ),
      body: Column(
        children: [
          Consumer(builder: (context, ref, child) {
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
                    myList
                        .add({"role": "user", "content": thisListe[i].message});
                    print(thisListe[i].message);
                  } else {
                    myList.add(
                        {"role": "assistant", "content": thisListe[i].message});
                  }
                }
                lastChat.addAll(myList);

                print("Last chat a pour taille ${lastChat.length}");
                //aiHandler.getResponse(myList, "message", widget.sessionId);
              }

              chats.addAll(list.reversed);
              if (chats.isNotEmpty) {
                print(!chats.first.isMe);
                if (!chats.first.isMe) {
                  currentMessage = chats.first.message;
                }
              }
            }
            return chats.isEmpty
                ? SingleChildScrollView(
                    child: Expanded(
                      child: Column(
                        children: [
                          firdtMessage(
                              "Hi! You can send your message or get inspired from suggestion."),
                          SizedBox(
                            height: MediaQuery.of(context).size.height -
                                MediaQuery.of(context).size.height * 0.47,
                          )
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: chats.length,
                      itemBuilder: (context, index) => ChatItem(
                        text: chats[index].message,
                        isMe: chats[index].isMe,
                      ),
                    ),
                  );
          }),
          // Padding(
          //   padding: const EdgeInsets.all(12.0),
          //   child: TextAndVoiceField(
          //     lastChat,
          //     id: widget.sessionId,
          //     message: widget.messageTopics,
          //   ),
          // ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.121),
        ],
      ),
    );
  }

  Widget firdtMessage(String message) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.37,
      decoration: const BoxDecoration(color: Color.fromARGB(255, 40, 54, 40)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const ProfileContainer(isMe: false),
              Container(
                padding: const EdgeInsets.all(15),
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
                    Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10)),
                          child: TextButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (con) {
                                      return SuggestionForm();
                                    });
                              },
                              icon: const Icon(
                                Icons.sms_failed,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Suggestion",
                                style: TextStyle(color: Colors.white),
                              )),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container _buildBottomSheet(BuildContext context) {
    return Container(
      key: _containerKey, // Ajout de la clé
      height: MediaQuery.of(context).size.height * 0.12,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white10,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextAndVoiceField(
        lastChat,
        id: widget.sessionId,
        message: widget.messageTopics,
      ),
    );
  }
}

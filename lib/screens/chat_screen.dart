import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_flutter/models/Discussion.dart';
import 'package:gpt_flutter/models/chat_model.dart';
import '../providers/chats_provider.dart';
import '../services/ai_handler.dart';
import '../widgets/chat_item.dart';

import '../widgets/my_app_bar.dart';
import '../widgets/text_and_voice_field.dart';

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
  final AIHandler aiHandler = AIHandler();
  final List<ChatModel> list = [];
  int giveList = 0;
  List<Map<String, String>> lastChat = [];

  @override
  void dispose() {
    aiHandler.closeSession();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(sessionId: widget.sessionId),
      body: Column(
        children: [
          Expanded(
            child: Consumer(builder: (context, ref, child) {
              final chats = ref.watch(chatsProvider).reversed.toList();
              List<ChatModel> thisListe = [];
              thisListe.addAll(list.reversed);
              if (list != null && list != []) {
                if (giveList == 0) {
                  giveList += 1;
                  List<Map<String, String>> myList = [];
                  for (int i = 0; i < thisListe.length; i++) {
                    print(thisListe[i].isMe);
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
              }
              return ListView.builder(
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
            padding: EdgeInsets.all(12.0),
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
}

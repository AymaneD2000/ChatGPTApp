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
  ChatScreen({Key? key, required this.sessionId, this.list});
  static const String id = 'chat';
  final List<Discussion>? list;
  final int sessionId;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AIHandler aiHandler = AIHandler();
  final List<ChatModel> list = [];

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
              if (list != null && list != []) {
                // list.forEach((element) {
                //   if (element.isMe == true)
                //     aiHandler.getResponse(element.message, widget.sessionId);
                // });
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
            child: TextAndVoiceField(id: widget.sessionId),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

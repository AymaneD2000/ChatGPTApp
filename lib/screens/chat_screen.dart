import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chats_provider.dart';
import '../services/ai_handler.dart';
import '../widgets/chat_item.dart';

import '../widgets/my_app_bar.dart';
import '../widgets/text_and_voice_field.dart';

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  ChatScreen(this.list, {super.key, required this.sessionId});
  static const String id = 'chat';
  List<Map<String, String>>? list;
  int sessionId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AIHandler aiHandler = AIHandler();

  @override
  void dispose() {
    aiHandler.closeSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          sessionId: widget.sessionId,
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer(builder: (context, ref, child) {
                final chats = ref.watch(chatsProvider).reversed.toList();
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
                id: widget.sessionId,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ));
  }
}

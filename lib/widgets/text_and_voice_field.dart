import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import '../providers/chats_provider.dart';
import '../services/ai_handler.dart';
import '../services/voice_handler.dart';
import 'toggle_button.dart';

enum InputMode {
  text,
  voice,
}

class TextAndVoiceField extends ConsumerStatefulWidget {
  final int id;
  final String? message;
  final List<Map<String, String>>? lastChat;
  const TextAndVoiceField(this.lastChat,
      {Key? key, this.message, required this.id})
      : super(key: key);

  @override
  ConsumerState<TextAndVoiceField> createState() => _TextAndVoiceFieldState();
}

class _TextAndVoiceFieldState extends ConsumerState<TextAndVoiceField> {
  late InputMode _inputMode;
  late TextEditingController _messageController;
  final AIHandler _openAI = AIHandler();
  final VoiceHandler _voiceHandler = VoiceHandler();
  bool _isReplying = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _inputMode = InputMode.voice;
    _messageController = TextEditingController(text: widget.message);
    _voiceHandler.initSpeech();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _openAI.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      child: Row(
        children: [
          Flexible(
            child: TextField(
              showCursor: true,
              expands: true,
              maxLines: null,
              controller: _messageController,
              onChanged: (value) {
                value.isNotEmpty
                    ? setInputMode(InputMode.text)
                    : setInputMode(InputMode.voice);
              },
              cursorColor: Theme.of(context).colorScheme.onPrimary,
              decoration: InputDecoration(
                labelText: "As me some thing",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 6,
          ),
          ToggleButton(
            isListening: _isListening,
            isReplying: _isReplying,
            inputMode: InputMode.text,
            sendTextMessage: () {
              final message = _messageController.text;
              _messageController.clear();
              sendTextMessage(message, widget.id);
            },
            sendVoiceMessage: sendVoiceMessage,
          ),
        ],
      ),
    );
  }

  void setInputMode(InputMode inputMode) {
    setState(() {
      _inputMode = inputMode;
    });
  }

  Future<void> sendVoiceMessage() async {
    if (!_voiceHandler.isEnabled) {
      print('Not supported');
      return;
    }
    if (_voiceHandler.speechToText.isListening) {
      await _voiceHandler.stopListening();
      setListeningState(false);
    } else {
      setListeningState(true);
      final result = await _voiceHandler.startListening();
      setListeningState(false);
      sendTextMessage(result, widget.id);
    }
  }

  Future<void> sendTextMessage(String message, int sessionId) async {
    setReplyingState(true);
    addToChatList(message, true, DateTime.now().toString());
    addToChatList('Typing...', false, 'typing');
    setInputMode(InputMode.voice);
    final aiResponse =
        await _openAI.getResponse(widget.lastChat, message, sessionId);
    removeTyping();
    addToChatList(aiResponse, false, DateTime.now().toString());
    setReplyingState(false);
    // ref.read(chatsProvider.notifier).clean();
  }

  void setReplyingState(bool isReplying) {
    setState(() {
      _isReplying = isReplying;
    });
  }

  void setListeningState(bool isListening) {
    setState(() {
      _isListening = isListening;
    });
  }

  void removeTyping() {
    final chats = ref.read(chatsProvider.notifier);
    chats.removeTyping();
  }

  void addToChatList(String message, bool isMe, String id) {
    final chats = ref.read(chatsProvider.notifier);

    chats.add(ChatModel(
      id: id,
      message: message,
      isMe: isMe,
    ));
  }
}

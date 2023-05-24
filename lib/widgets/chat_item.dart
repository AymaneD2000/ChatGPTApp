import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share/share.dart';

class ChatItem extends StatefulWidget {
  final String text;
  final bool isMe;
  const ChatItem({
    super.key,
    required this.text,
    required this.isMe,
  });

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  bool isSpeacking = false;
  late FlutterTts text_to_speech;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    text_to_speech = FlutterTts();
  }

  Future _speack(String texte) async {
    await text_to_speech.setLanguage('en-US');
    await text_to_speech.setPitch(1.0);
    await text_to_speech.speak(texte);
    //await text_to_speech.awaitSpeakCompletion(isSpeacking);
  }

  Future stop() async {
    await text_to_speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 12,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!widget.isMe) ProfileContainer(isMe: widget.isMe),
              if (!widget.isMe) const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.all(15),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.60,
                ),
                decoration: BoxDecoration(
                  color: widget.isMe
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey.shade800,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15),
                    topRight: const Radius.circular(15),
                    bottomLeft: Radius.circular(widget.isMe ? 15 : 0),
                    bottomRight: Radius.circular(widget.isMe ? 0 : 15),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.text));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        duration: Duration(seconds: 0),
                        content: Text("Text copied to clipboard")));
                  },
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ),
              if (widget.isMe) const SizedBox(width: 15),
              if (widget.isMe) ProfileContainer(isMe: widget.isMe),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              //Boutton pour lire du texte et arreter la lecture
              IconButton(
                  onPressed: () async {
                    setState(() {
                      isSpeacking = !isSpeacking;
                      print(isSpeacking);
                    });
                    if (isSpeacking) {
                      _speack(widget.text).then((value) {
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
                  icon:
                      Icon((isSpeacking) ? Icons.volume_up : Icons.volume_off)),

              //Boutton pour copier du texte
              IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.text));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        duration: Duration(seconds: 1),
                        content: Text("Text copied to clipboard")));
                  },
                  icon: const Icon(Icons.copy)),
              //boutton pour envoye du texte
              IconButton(
                  onPressed: () {
                    print(widget.text);
                    Share.share(widget.text);
                  },
                  icon: const Icon(Icons.share)),
            ],
          )
        ],
      ),
    );
  }
}

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({
    super.key,
    required this.isMe,
  });

  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isMe
            ? Theme.of(context).colorScheme.secondary
            : Colors.grey.shade800,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
          bottomLeft: Radius.circular(isMe ? 0 : 15),
          bottomRight: Radius.circular(isMe ? 15 : 0),
        ),
      ),
      child: Icon(
        isMe ? Icons.person : Icons.computer,
        color: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}

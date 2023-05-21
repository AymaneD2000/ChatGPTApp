import 'package:flutter/material.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:gpt_flutter/providers/Database_Manager.dart';
import 'package:gpt_flutter/screens/home_screen.dart';
import '../providers/active_theme_provider.dart';
import '../providers/chats_provider.dart';
import 'theme_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_handler.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  int sessionId;
  MyAppBar({super.key, required this.sessionId});
  final AIHandler aiHandler = AIHandler();
  final db = DatabaseManager.instance;
  void _openSession() {
    aiHandler.openSession();
  }

  void _closeSession() {
    aiHandler.closeSession();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const SizedBox(width: 8),
          Consumer(builder: (context, ref, child) {
            final chats = ref.read(chatsProvider.notifier);
            chats.removeTyping();
            return GestureDetector(
              child: Icon(Icons.stop),
              onTap: () async {
                final chats = ref.read(chatsProvider.notifier);
                chats.clean();
                print("getting");
                //await aiHandler.getResponse("getList", sessionId);
                print("got it");
                final result = await db.getSessionForGlobal(sessionId);
                final number = result.length;

                if (number == 0) {
                  try {
                    await db.deleteGlobalSession(sessionId);
                  } catch (e) {
                    print(e);
                  }
                } else {
                  print("Saved");
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
          Spacer(),
          Text(
            'Zetron - AI',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          Spacer(),
          Consumer(
            builder: (context, ref, child) => Icon(
              ref.watch(activeThemeProvider) == Themes.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
          const SizedBox(width: 8),
          const ThemeSwitch(),
        ],
      ),
      actions: [
        Row(
          children: [],
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

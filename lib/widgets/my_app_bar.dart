// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/src/consumer.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:gpt_flutter/providers/Database_Manager.dart';
// import 'package:gpt_flutter/screens/home_screen.dart';
// import '../providers/active_theme_provider.dart';
// import '../providers/chats_provider.dart';
// import 'theme_switch.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/ai_handler.dart';

// class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
//   int sessionId;
//   String recentAIresponse;
//   MyAppBar(
//       {super.key, required this.recentAIresponse, required this.sessionId});
//   final AIHandler aiHandler = AIHandler();
//   final db = DatabaseManager.instance;
//   void _openSession() {
//     aiHandler.openSession();
//   }

  

//   Future _speack(String texte) async {
//     await text_to_speech.setLanguage('en-US');
//     await text_to_speech.setPitch(1.0);
//     await text_to_speech.speak(texte);
//   }

//   Future stop() async {
//     await text_to_speech.stop();
//   }

//   void _closeSession() {
//     aiHandler.closeSession();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.black,
//       automaticallyImplyLeading: false,
//       title: Row(
//         children: [
//           const SizedBox(width: 8),
//           Consumer(builder: (context, ref, child) {
//             final chats = ref.read(chatsProvider.notifier);
//             chats.removeTyping();
//             return GestureDetector(
//               child: Icon(
//                 Icons.close,
//               ),
//               onTap: () async {
//                 final chats = ref.read(chatsProvider.notifier);
//                 chats.clean();

//                 final result = await db.getSessionForGlobal(sessionId);
//                 final number = result.length;

//                 if (number == 0) {
//                   try {
//                     await db.deleteGlobalSession(sessionId);
//                   } catch (e) {
//                     print(e);
//                   }
//                 } else {
//                   print("Saved");
//                 }
//                 _closeSession;
//                 // ignore: use_build_context_synchronously
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => HomeScreen(),
//                   ),
//                 );
//               },
//             );
//           }),
//           Spacer(),
//           Text(
//             'Zetron - AI',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.onPrimary,
//             ),
//           ),
//           Spacer(),
//           IconButton(
//               onPressed: () async {
//                 await stop();
//                 setState(() {
//                   isSpeacking = !isSpeacking;
//                   print(isSpeacking);
//                 });
//                 if (isSpeacking) {
//                   _speack(widget.text).then((value) {
//                     setState(() {
//                       isSpeacking = false;
//                     });
//                   });
//                 } else {
//                   await stop();
//                   setState(() {
//                     isSpeacking = false;
//                   });
//                 }
//                 print(isSpeacking);
//               },
//               icon: const Icon(Icons.volume_up)),
//         ],
//       ),
//       actions: [
//         Row(
//           children: [],
//         )
//       ],
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(60);
// }

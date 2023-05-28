import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/Session.dart';
import '../providers/Database_Manager.dart';
import '../providers/active_theme_provider.dart';
import '../screens/chat_screen.dart';
import '../screens/setting_screen.dart';
import '../services/ai_handler.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget({
    super.key,
  });

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final AIHandler aiHandler = AIHandler();

  final DatabaseManager _databaseManager = DatabaseManager.instance;

  late Future<List<Session>> globalSessionsFuture;

  @override
  Widget build(BuildContext context) {
    globalSessionsFuture = _databaseManager.getAllGlobalSessions();
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: const Text(
              "Your history",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: TextButton(
              child: Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return const Setting();
                        }));
                      },
                      child: Row(
                        children: [
                          Consumer(
                              builder: (context, ref, child) => IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    size: 35,
                                    Icons.settings,
                                    color: ref.watch(activeThemeProvider) ==
                                            Themes.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ))),
                          Consumer(
                              builder: (context, ref, child) => Text(
                                    "Settings",
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: ref.watch(activeThemeProvider) ==
                                                Themes.dark
                                            ? Colors.white
                                            : Colors.black),
                                  )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
//Consumer(
          //   builder: (context, ref, child) {
          //     final theme = ref.watch(activeThemeProvider);
          //     return Center(
          //       child: Container(
          //         width: MediaQuery.of(context).size.width * 0.9,
          //         height: MediaQuery.of(context).size.height * 0.6,
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(10),
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.black.withOpacity(0.1),
          //               blurRadius: 5,
          //               offset: Offset(0, 2),
          //             ),
          //           ],
          //         ),
          //         child: ListView.builder(
          //           shrinkWrap: true,
          //           itemCount: topics.length,
          //           itemBuilder: (context, index) {
          //             return Container(
          //               margin: EdgeInsets.symmetric(vertical: 8),
          //               decoration: BoxDecoration(
          //                 color: Colors.white,
          //                 borderRadius: BorderRadius.circular(8),
          //                 boxShadow: [
          //                   BoxShadow(
          //                     color: Colors.black.withOpacity(0.1),
          //                     blurRadius: 3,
          //                     offset: Offset(0, 2),
          //                   ),
          //                 ],
          //               ),
          //               child: Center(
          //                 child: DiscussionsExpansionTile(
          //                   discussions: topics[index],
          //                 ),
          //               ),
          //             );
          //           },
          //         ),
          //       ),
          //     );
          //   },
          // ),
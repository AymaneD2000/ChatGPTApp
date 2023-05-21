import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/active_theme_provider.dart';
import '../screens/setting_screen.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: Container(),
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

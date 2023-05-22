import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gpt_flutter/screens/privacy_polici_page.dart';
import 'package:gpt_flutter/screens/term_of_service_page.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Map<String, Icon> list = {
    "Follow on Twitter": Icon(FlutterIcons.twitter_ant)
  };
  List<Map<String, Icon>> lister = [
    {
      "Follow on Twitter": const Icon(
        FlutterIcons.twitter_ant,
        color: Colors.blue,
      )
    },
    {
      "Follow on Twitter": Icon(
        FlutterIcons.reddit_alien_faw,
        color: Colors.red,
      )
    },
    {
      "Like us,Rate us ?": const Icon(
        FlutterIcons.star_ant,
      )
    },
    {
      "About Codeway ": const Icon(
        FlutterIcons.code_array_mco,
      )
    },
  ];
  List<Map<String, Icon>> lister1 = [
    {
      "E-mail Support": const Icon(
        Icons.email,
      )
    },
    {
      "Restore Purchase": const Icon(
        Icons.sync,
      )
    },
  ];
  List<Map<String, Icon>> lister2 = [
    {
      "Privacy Policy": const Icon(
        Icons.security_outlined,
      )
    },
    {
      "Terms of Service": const Icon(
        FlutterIcons.file_document_box_mco,
      )
    },
    {
      "Community Guideline": const Icon(
        FlutterIcons.file_alt_faw5s,
      )
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 95,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30)),
              child: Card(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.transparent)),
                child: Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
                    Container(
                      padding: EdgeInsets.only(left: 20),
                      child: const Text(
                        "Share Ask AI",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
            //Twittwer etc...
            Container(
              padding: EdgeInsets.fromLTRB(9, 0, 9, 0),
              child: Card(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.transparent)),
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                        parent: NeverScrollableScrollPhysics()),
                    shrinkWrap: true,
                    itemCount: lister.length,
                    itemBuilder: (BuildContext context, i) {
                      return Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Card(
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: lister[i].values.first,
                                color: Colors.blue,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  lister[i].keys.first,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
            //mail et purchase
            Container(
              padding: EdgeInsets.fromLTRB(9, 15, 9, 0),
              child: Card(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.transparent)),
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                        parent: NeverScrollableScrollPhysics()),
                    shrinkWrap: true,
                    itemCount: lister1.length,
                    itemBuilder: (BuildContext context, i) {
                      return Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Card(
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: lister1[i].values.first,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  lister1[i].keys.first,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(9, 15, 9, 0),
              child: Card(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.transparent)),
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                        parent: NeverScrollableScrollPhysics()),
                    shrinkWrap: true,
                    itemCount: lister2.length,
                    itemBuilder: (BuildContext context, i) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            if (i == 0) {
                              return PrivacyPolicy();
                            } else if (i == 1) {
                              return TermsOfService();
                            } else {
                              return Container();
                            }
                          }));
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Card(
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: lister2[i].values.first,
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(
                                    lister2[i].keys.first,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
}

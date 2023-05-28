import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gpt_flutter/screens/privacy_polici_page.dart';
import 'package:gpt_flutter/screens/rate_screen.dart';
import 'package:gpt_flutter/screens/term_of_service_page.dart';
import 'package:url_launcher/url_launcher.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Map<String, Icon> list = {
    "Follow on Twitter": const Icon(FlutterIcons.twitter_ant)
  };
  List<Map<String, Icon>> lister = [
    {
      "Follow on Twitter": const Icon(
        FlutterIcons.twitter_ant,
        color: Colors.blue,
      )
    },
    {
      "Follow on Twitter": const Icon(
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
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30)),
              child: Card(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.transparent)),
                child: Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
                    Container(
                      padding: const EdgeInsets.only(left: 20),
                      child: const Text(
                        "Share Zetron AI",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
            //Twittwer etc...
            Container(
              padding: const EdgeInsets.fromLTRB(9, 0, 9, 0),
              child: Card(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.transparent)),
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                        parent: NeverScrollableScrollPhysics()),
                    shrinkWrap: true,
                    itemCount: lister.length,
                    itemBuilder: (BuildContext context, i) {
                      return Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Card(
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (lister[i].keys.first ==
                                      "Like us,Rate us ?") {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return RateUsDialog();
                                      },
                                    );
                                  }
                                },
                                icon: lister[i].values.first,
                                color: Colors.blue,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (lister[i].keys.first ==
                                      "Like us,Rate us ?") {
                                    // showDialog(
                                    //   context: context,
                                    //   builder: (BuildContext context) {
                                    //     return RateUsDialog();
                                    //   },
                                    // );
                                    launchPlayStoreForRating();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    lister[i].keys.first,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
              padding: const EdgeInsets.fromLTRB(9, 15, 9, 0),
              child: Card(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.transparent)),
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                        parent: NeverScrollableScrollPhysics()),
                    shrinkWrap: true,
                    itemCount: lister1.length,
                    itemBuilder: (BuildContext context, i) {
                      return Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Card(
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: lister1[i].values.first,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 20),
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
              margin: const EdgeInsets.fromLTRB(9, 15, 9, 0),
              child: Card(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.transparent)),
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
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Card(
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: lister2[i].values.first,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 20),
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

void showRateAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Noter l'application"),
        content: const Text("Aimez-vous utiliser cette application ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Non"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              launchPlayStoreForRating();
            },
            child: const Text("Oui"),
          ),
        ],
      );
    },
  );
}

void launchPlayStoreForRating() async {
  final Uri _url = Uri.parse("com.android.chrome");
  String appPackageName = "com.android.chrome";
  final Uri surl = Uri.parse(
      'https://play.google.com/store/apps/details?id=$appPackageName');
  final String url = 'market://details?id=$appPackageName';
  if (await canLaunchUrl(_url)) {
    await launchUrl(_url);
  } else {
    await launchUrl(surl);
  }
}

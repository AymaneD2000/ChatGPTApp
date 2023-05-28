import 'package:flutter/material.dart';
import 'home_screen.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen();

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  Widget feature(IconData icon, String title, String subTitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      subtitle: Text(
        subTitle,
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  String tile = 'Unlock Unlimited Access';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          child: const Icon(Icons.close, color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.restore, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              tile,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  feature(
                    Icons.stars,
                    "Answers from GPT3.5",
                    "More accurate & detailed answers",
                  ),
                  const Divider(color: Colors.grey),
                  feature(
                    Icons.double_arrow,
                    "Higher word limit",
                    "Type longer messages",
                  ),
                  const Divider(color: Colors.grey),
                  feature(
                    Icons.add,
                    "No Limits",
                    "Have unlimited dialogues",
                  ),
                  const Divider(color: Colors.grey),
                  feature(
                    Icons.ads_click,
                    "No Ads",
                    "Enjoy Zetron AI without any ads",
                  ),
                  const Divider(color: Colors.grey),
                  feature(
                    Icons.restart_alt,
                    "Restart conversation",
                    "Remember all of your last conversation",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "3 days Free Trial, Auto Renewal",
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  "\u20AC 7.38/Week",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "Start Free Trial and Plan",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

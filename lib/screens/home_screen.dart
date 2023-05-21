import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_flutter/models/Discussion.dart';
import 'package:gpt_flutter/screens/chat_screen.dart';
import 'package:gpt_flutter/screens/setting_screen.dart';
import 'package:gpt_flutter/widgets/home_app_bar.dart';

import '../models/Session.dart';
import '../providers/Database_Manager.dart';
import '../providers/active_theme_provider.dart';
import '../services/ai_handler.dart';
import '../widgets/drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class Discussions {
  String topic;
  List<String> suggestions;
  Discussions({required this.topic, required this.suggestions});
}

class _HomeScreenState extends State<HomeScreen> {
  final AIHandler aiHandler = AIHandler();
  final DatabaseManager _databaseManager = DatabaseManager.instance;

  List<Discussions> topics = [
    Discussions(
      topic: 'Education',
      suggestions: [
        'Science chat',
        'English teacher',
        'Mathematics help',
      ],
    ),
    Discussions(
      topic: 'Technology',
      suggestions: [
        'Programming discussion',
        'Gadgets and devices',
        'AI and Machine Learning',
      ],
    ),
    // Add more topics and suggestions as needed
  ];
  List<String> currentSuggestions = [];

  void _openSession() async {
    int id = await _databaseManager.saveGlobalSession('sessionName');
    Session session = Session(id: id, name: 'sessionName');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          sessionId: session.id,
        ),
      ),
    );
  }

  void updateSuggestions(String topic) {
    Discussions? selectedDiscussion = topics.firstWhere(
      (discussion) => discussion.topic == topic,
      orElse: () => Discussions(topic: '', suggestions: []),
    );

    if (selectedDiscussion != null) {
      setState(() {
        currentSuggestions = selectedDiscussion.suggestions;
      });
    } else {
      setState(() {
        currentSuggestions = [];
      });
    }
  }

  @override
  void dispose() {
    aiHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: HomeAppBar(),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topics.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    updateSuggestions(topics[index].topic);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    margin: EdgeInsets.all(8),
                    color: Colors.blue, // Customize as needed
                    child: Center(
                      child: Text(
                        topics[index].topic,
                        style: TextStyle(
                          color: Colors.white, // Customize as needed
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: currentSuggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(currentSuggestions[index]),
                  onTap: () {
                    // Handle suggestion selection
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openSession,
        child: Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gpt_flutter/screens/chat_screen.dart';

import '../models/Session.dart';
import '../models/discussions.dart';
import '../providers/Database_Manager.dart';
import '../screens/home_screen.dart';

class DiscussionsExpansionTile extends StatefulWidget {
  final Discussions discussions;

  const DiscussionsExpansionTile({required this.discussions});

  @override
  _DiscussionsExpansionTileState createState() =>
      _DiscussionsExpansionTileState();
}

class _DiscussionsExpansionTileState extends State<DiscussionsExpansionTile> {
  bool _isExpanded = false;
  final DatabaseManager _databaseManager = DatabaseManager.instance;
  void _openSession(String message) async {
    int id = await _databaseManager.saveGlobalSession('sessionName');
    Session session = Session(id: id, name: 'sessionName');
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          sessionId: session.id,
          messageTopics: message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.0),
          title: Text(
            widget.discussions.topic,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: Theme.of(context).textTheme.headlineSmall!.color,
            ),
            textAlign: TextAlign.center,
          ),
          iconColor: Theme.of(context).iconTheme.color,
          collapsedIconColor: Theme.of(context).iconTheme.color,
          collapsedTextColor: Theme.of(context).textTheme.bodyText1!.color,
          textColor: Theme.of(context).textTheme.bodyText1!.color,
          backgroundColor: Theme.of(context).cardColor,
          collapsedBackgroundColor: Theme.of(context).cardColor,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: widget.discussions.suggestions.map((suggestion) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                title: Text(
                  suggestion.suggestions,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).textTheme.bodyText1!.color,
                  ),
                ),
                onTap: () {
                  _openSession(suggestion.suggestionPrompt);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

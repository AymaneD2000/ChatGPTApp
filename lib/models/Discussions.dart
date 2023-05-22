import 'package:gpt_flutter/models/suggestion.dart';

class Discussions {
  String topic;
  List<Suggestion> suggestions;
  Discussions({required this.topic, required this.suggestions});
}

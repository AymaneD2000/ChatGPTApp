import 'package:flutter/material.dart';
import 'package:gpt_flutter/models/suggestion.dart';

class Discussions {
  String topic;
  IconData icon;
  List<Suggestion> suggestions;
  Discussions({required this.topic, required this.suggestions, required this.icon});
}

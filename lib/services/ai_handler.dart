// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:gpt_flutter/constants/const.dart';

import '../providers/Database_Manager.dart';

class AIHandler {
  final DatabaseManager _databaseManager = DatabaseManager.instance;
  List<List<String>> conversationSessions = [];
  bool isSessionOpen = false;
  FirebaseMangement manage = FirebaseMangement();
  List<String> currentSession = [];
  List<Map<String, String>> list = [];
  int isListGetted = 0;

  void openSession() {
    currentSession.clear();
    isSessionOpen = true;
  }

  void closeSession() {
    if (currentSession.isNotEmpty) {
      conversationSessions.add(List.from(currentSession));
      currentSession.clear();
    }
  }

  static var api = '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';

  final _openAI = OpenAI.instance.build(
    token: api,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 60),
      connectTimeout: const Duration(seconds: 60),
    ),
  );

  Future<String> getResponse(List<Map<String, String>>? newList, String message,
      int? sessionId) async {
    if (newList != null && isListGetted == 0) {
      isListGetted += 1;

      list.addAll(newList);
    }
    try {
      list.add({"role": "user", "content": message});

      //Map.of({"role": "user", "content": message})
      final request = ChatCompleteText(
          messages: list, maxToken: 800, model: ChatModel.gptTurbo0301);
      //final rep = request.messages[0].values;
      final response = await _openAI.onChatCompletion(request: request);

      if (response != null) {
        String reply = response.choices[0].message!.content.trim();
        List<String> session = [message, reply];

        //Tranformer la liste des discussions de cette session en Json pour pouvoir stocker
        //la liste tout entier dans sqflite

        String listToJson = jsonEncode(list);

        //mise a jour de la liste dans la base de donnees
        await _databaseManager.deleteSessionListe(sessionId!);
        await _databaseManager.saveSessionListe(listToJson, sessionId);
        //var lister = await _databaseManager.getAllSessionsListe(sessionId);
        list.add({"role": "assistant", "content": reply});

        await _databaseManager.saveSession(session, sessionId);

        return reply;
      }

      return 'Some thing went wrong';
    } catch (e) {
      print(e);
      return 'Bad response';
    }
  }

  void dispose() {
    _openAI;
    isSessionOpen = false;
  }
}

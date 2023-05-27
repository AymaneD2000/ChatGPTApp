// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

import '../providers/Database_Manager.dart';

class AIHandler {
  final DatabaseManager _databaseManager = DatabaseManager.instance;
  List<List<String>> conversationSessions = [];
  bool isSessionOpen = false;

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

  final _openAI = OpenAI.instance.build(
    token: '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',
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 60),
      connectTimeout: const Duration(seconds: 60),
    ),
  );

  Future<String> getResponse(
      List<Map<String, String>>? newList, String message, int sessionId) async {
    if (newList != null && isListGetted == 0) {
      isListGetted += 1;

      list.addAll(newList);
    }
    try {
      print(list.length);

      list.add({"role": "user", "content": message});
      print(list.length);

      //Map.of({"role": "user", "content": message})
      final request = ChatCompleteText(
          messages: list, maxToken: 800, model: ChatModel.gptTurbo0301);
      //final rep = request.messages[0].values;
      final response = await _openAI.onChatCompletion(request: request);

      print(response);
      if (response != null) {
        String reply = response.choices[0].message!.content.trim();
        List<String> session = [message, reply];
        print("longueur de la liste lors du get ${list.length}");

        //Tranformer la liste des discussions de cette session en Json pour pouvoir stocker
        //la liste tout entier dans sqflite

        String listToJson = jsonEncode(list);
        print("La liste en format Json $listToJson");
        //mise a jour de la liste dans la base de donnees
        await _databaseManager.deleteSessionListe(sessionId);
        await _databaseManager.saveSessionListe(listToJson, sessionId);
        //var lister = await _databaseManager.getAllSessionsListe(sessionId);
        list.add({"role": "assistant", "content": reply});
        print("longueur de la liste avant get ${list.length}");
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

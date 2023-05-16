import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

import '../providers/Database_Manager.dart';

class AIHandler {
  final DatabaseManager _databaseManager = DatabaseManager.instance;
  List<List<String>> conversationSessions = [];
  bool isSessionOpen = false;
  List<String> currentSession = [];

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

  Future<String> getResponse(String message) async {
    try {
      final request = ChatCompleteText(messages: [
        Map.of({"role": "user", "content": message})
      ], maxToken: 200, model: ChatModel.gptTurbo0301);
        final rep = request.messages[0].values;
      final response = await _openAI.onChatCompletion(request: request);
    if (response != null) {
      String reply = response.choices[0].message!.content.trim();
      List<String> session = [message, reply];
      await _databaseManager.saveSession(session);
      return reply;
    }

      return 'Some thing went wrong';
    } catch (e) {
      return 'Bad response';
    }
  }

  Future<List<List<String>>> getConversationSessions() async {
    return _databaseManager.getAllSessions();
  }


  void dispose() {
    _openAI;
    isSessionOpen = false;
  }
}

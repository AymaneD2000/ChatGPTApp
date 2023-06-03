import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

import 'ai_handler.dart';

class SessionName {
  List<Map<String, String>> list = [];
  final _openAI = OpenAI.instance.build(
    token: AIHandler.api,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 60),
      connectTimeout: const Duration(seconds: 60),
    ),
  );
  Future<String> getResponse(String message) async {
    try {
      list.add({"role": "user", "content": message});
      final request = ChatCompleteText(
          messages: list, maxToken: 800, model: ChatModel.gptTurbo0301);
      //final rep = request.messages[0].values;
      final response = await _openAI.onChatCompletion(request: request);
      if (response != null) {
        String reply = response.choices[0].message!.content.trim();
        return reply.toString();
      }
      return 'Some thing went wrong';
    } catch (e) {
      print(e);
      return 'Bad response';
    }
  }
}

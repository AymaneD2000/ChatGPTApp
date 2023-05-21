class Discussion {
  int id;
  String userMessage;
  String aiReply;
  int sessionId;

  Discussion(
      {required this.id,
      required this.userMessage,
      required this.aiReply,
      required this.sessionId});

  Map<String, dynamic> toMap() => {
        'id': id,
        'userMessage': userMessage,
        'aiReply': aiReply,
        'session_id': sessionId
      };
  factory Discussion.fromMap(Map<String, dynamic> map) {
    return Discussion(
        id: map['id'],
        userMessage: map['userMessage'],
        aiReply: map['aiReply'],
        sessionId: map['session_id']);
  }
}

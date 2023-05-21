import 'Discussion.dart';

class DiscussionList {
  int id;
  String name;
  int sessionId;
  List<Discussion>? discussions;

  DiscussionList(
      {required this.id,
      required this.name,
      required this.sessionId,
      this.discussions});
  Map<String, dynamic> toMap() =>
      {'id': id, 'list': name, 'session_id': sessionId};
  factory DiscussionList.fromMap(Map<String, dynamic> data) {
    return DiscussionList(
      id: data['id'],
      name: data['list'],
      sessionId: data['session_id'],
      discussions: data['discussion'] == null
          ? []
          : List<Discussion>.from(data['discussions']
              .map((element) => Discussion.fromMap(element))),
    );
  }
}

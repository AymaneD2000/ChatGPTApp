import 'Discussion.dart';

class Session {
  int id;
  String name;
  List<Discussion>? discussions;

  Session({required this.id, required this.name, this.discussions});
  Map<String, dynamic> toMap() => {
        'id': id,
        'sessionName': name,
      };
  factory Session.fromMap(Map<String, dynamic> data) {
    return Session(
      id: data['id'],
      name: data['sessionName'],
      discussions: data['discussion'] == null
          ? []
          : List<Discussion>.from(data['discussions']
              .map((element) => Discussion.fromMap(element))),
    );
  }
}

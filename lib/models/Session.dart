import 'Discussion.dart';

class Session {
  final int id;
  final String name;
  final List<Discussion>? discussions;

  Session({required this.id, required this.name, this.discussions});
  Map<String, dynamic> toMap() => {
        'id': id,
        'sessionName': name,
      };
}

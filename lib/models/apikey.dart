import 'package:cloud_firestore/cloud_firestore.dart';

class Apikey {
  String key;
  String? documentId;
  Apikey({required this.documentId, required this.key});
  factory Apikey.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> file) {
    final data = file.data();
    return Apikey(
      key: data!["key"],
      documentId: file.id,
    );
  }
}

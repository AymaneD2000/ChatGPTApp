import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '';

import '../models/apikey.dart';

// Exemple de lecture de données à partir de Firestor

class FirebaseMangement {
  final _db = FirebaseFirestore.instance;

  Future<String> getAdmin() async {
    final snapshot = await _db.collection("API_Key").get();
    final userData = snapshot.docs.map((e) => Apikey.fromSnapshot(e)).toList();
    return userData.first.key;
  }

// Exemple d'écriture de données dans Firestore
  writeData() {
    String key = "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";
    FirebaseFirestore.instance
        .collection('API_Key') // Remplacez par le nom de votre collection
        .doc() // Remplacez par l'ID du document
        .set({'key': key})
        .then((value) => print('Données écrites avec succès'))
        .catchError((error) =>
            print('Erreur lors de l\'écriture des données : $error'));
  }
}

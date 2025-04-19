import 'package:cloud_firestore/cloud_firestore.dart';

class Talk {
  String content;
  String sender;
  DateTime createdAt;

  Talk({required this.content, required this.sender, required this.createdAt});

  factory Talk.fromSnapShot(DocumentSnapshot snapshot) {
    return Talk(
      content: snapshot.get('content'),
      sender: snapshot.get('sender'),
      createdAt: (snapshot.get('createdAt') as Timestamp).toDate(),
    );
  }

  toJson() {
    return {
      "content": content,
      "sender": sender,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }
}

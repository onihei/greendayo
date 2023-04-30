import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  List<String> members;
  DateTime updatedAt;

  Session({
    required this.members,
    required this.updatedAt,
  });

  factory Session.fromSnapShot(DocumentSnapshot snapshot) {
    return Session(
      members: [...snapshot.get('members')],
      updatedAt: (snapshot.get('updatedAt') as Timestamp).toDate(),
    );
  }

  toJson() {
    return {
      "members": members,
      "updatedAt": Timestamp.fromDate(updatedAt),
    };
  }
}

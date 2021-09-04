import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  String text;
  num left;
  num top;
  DateTime createdAt;
  String createdBy;

  Article(
    this.text,
    this.left,
    this.top,
    this.createdAt,
    this.createdBy,
  );

  factory Article.fromSnapShot(DocumentSnapshot snapshot) {
    return Article(
      snapshot.get('text'),
      snapshot.get('left'),
      snapshot.get('top'),
      (snapshot.get('createdAt') as Timestamp).toDate(),
      snapshot.get('createdBy'),
    );
  }

  toJson() {
    return {
      "text": text,
      "left": left,
      "top": top,
      "createdAt": Timestamp.fromDate(createdAt),
      "createdBy": createdBy,
    };
  }
}

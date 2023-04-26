import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  String text;
  String signature;
  num left;
  num top;
  num width;
  DateTime createdAt;
  String createdBy;

  Article({
    required this.text,
    required this.signature,
    required this.left,
    required this.top,
    required this.width,
    required this.createdAt,
    required this.createdBy,
  });

  factory Article.fromSnapShot(DocumentSnapshot snapshot) {
    return Article(
      text: snapshot.get('text'),
      signature: snapshot.get('signature'),
      left: snapshot.get('left'),
      top: snapshot.get('top'),
      width: snapshot.get('width'),
      createdAt: (snapshot.get('createdAt') as Timestamp).toDate(),
      createdBy: snapshot.get('createdBy'),
    );
  }

  toJson() {
    return {
      "text": text,
      "signature": signature,
      "left": left,
      "top": top,
      "width": width,
      "createdAt": Timestamp.fromDate(createdAt),
      "createdBy": createdBy,
    };
  }
}

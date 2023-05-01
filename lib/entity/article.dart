import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Article {
  String content;
  String signature;
  num left;
  num top;
  num width;
  DateTime createdAt;
  String createdBy;

  bool get isPhoto {
    return content.contains('<img');
  }

  Widget? get photoImage {
    if (!isPhoto) {
      return null;
    }
    final pattern = RegExp('<img src="(.+)" data-rotation="(.+)"');
    final matches = pattern.allMatches(content);
    if (matches.isEmpty) {
      return null;
    }
    final src = matches.single.group(1);
    if (src == null) {
      return null;
    }
    return Image.network(src);
  }

  double? get rotation {
    if (!isPhoto) {
      return null;
    }
    final pattern = RegExp('<img src="(.+)" data-rotation="(.+)"');
    final matches = pattern.allMatches(content);
    if (matches.isEmpty) {
      return null;
    }
    final rotation = matches.single.group(2);
    if (rotation == null) {
      return null;
    }
    return double.parse(rotation);
  }

  Article({
    required this.content,
    required this.signature,
    required this.left,
    required this.top,
    required this.width,
    required this.createdAt,
    required this.createdBy,
  });

  factory Article.fromSnapShot(DocumentSnapshot snapshot) {
    return Article(
      content: snapshot.get('content'),
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
      "content": content,
      "signature": signature,
      "left": left,
      "top": top,
      "width": width,
      "createdAt": Timestamp.fromDate(createdAt),
      "createdBy": createdBy,
    };
  }
}

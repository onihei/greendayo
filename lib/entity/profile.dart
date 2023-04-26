import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:greendayo/lang/firebase_ext.dart';

class Profile {
  final String userId;
  final String nickname;
  final String? photoUrl;

  final String? age;
  final String? born;
  final String? job;
  final String? interesting;
  final String? book;
  final String? movie;
  final String? goal;
  final String? treasure;

  Profile({
    required this.userId,
    required this.nickname,
    required this.photoUrl,
    this.age,
    this.born,
    this.job,
    this.interesting,
    this.book,
    this.movie,
    this.goal,
    this.treasure,
  });

  String get text {
    return "こんにちは、私は${nickname}と申します。${born}出身の${age}。現在は${job}として活動しています。"
        "空いた時間にはよく${interesting}をしています。"
        "私の好きな本は${book}、映画では${movie}が大好きです。"
        "\n\n\n"
        "将来の目標は${goal}。人生の宝物は${treasure}。";
  }

  Widget get photo {
    if (photoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: Container(
            width: 32,
            height: 32,
            child: Image.network(
              photoUrl!,
              fit: BoxFit.cover,
            )),
      );
    } else {
      return FaIcon(
        FontAwesomeIcons.circleUser,
        color: Colors.grey,
        size: 32,
      );
    }
  }

  Widget get photoLarge {
    if (photoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(160.0),
        child: Container(
            width: 160,
            height: 160,
            child: Image.network(
              photoUrl!,
              fit: BoxFit.cover,
            )),
      );
    } else {
      return FaIcon(
        FontAwesomeIcons.circleUser,
        color: Colors.grey,
        size: 160,
      );
    }
  }

  factory Profile.anonymous() {
    return Profile(
      userId: "anonymous",
      nickname: "no_name",
      photoUrl: null,
    );
  }

  factory Profile.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Profile(
      userId: snapshot.id,
      nickname: snapshot.get('nickname'),
      photoUrl: snapshot.get('photoUrl'),
      age: snapshot.getIfExists('age'),
      born: snapshot.getIfExists('born'),
      job: snapshot.getIfExists('job'),
      interesting: snapshot.getIfExists('interesting'),
      book: snapshot.getIfExists('book'),
      movie: snapshot.getIfExists('movie'),
      goal: snapshot.getIfExists('goal'),
      treasure: snapshot.getIfExists('treasure'),
    );
  }

  toJson() {
    return {
      "nickname": nickname,
      "photoUrl": photoUrl,
      "age": age,
      "born": born,
      "job": job,
      "interesting": interesting,
      "book": book,
      "movie": movie,
      "goal": goal,
      "treasure": treasure,
    };
  }

  Profile copyWith({
    String? userId,
    String? nickname,
    String? photoUrl,
    String? age,
    String? born,
    String? job,
    String? interesting,
    String? book,
    String? movie,
    String? goal,
    String? treasure,
  }) {
    return Profile(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      born: born ?? this.born,
      job: job ?? this.job,
      interesting: interesting ?? this.interesting,
      book: book ?? this.book,
      movie: movie ?? this.movie,
      goal: goal ?? this.goal,
      treasure: treasure ?? this.treasure,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/lang/firebase_ext.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  final String? text;

  Profile({
    required this.userId,
    required this.nickname,

    /// 認証時の画像
    required this.photoUrl,
    this.age,
    this.born,
    this.job,
    this.interesting,
    this.book,
    this.movie,
    this.goal,
    this.treasure,
    this.text,
  });

  Widget get photoSmall => _photo(32);

  Widget get photoMiddle => _photo(44);

  Widget get photoLarge => _photo(160);

  Widget _photo(double size) {
    return ClipRRect(
      key: ValueKey(size),
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        child: Consumer(builder: (context, ref, child) {
          if (userId == "anonymous") {
            return Icon(
              Icons.account_circle,
              size: size,
            );
          }
          final avatar = ref.watch(avatarProvider(userId));
          return avatar.when(
            data: (data) => Image.memory(
              data,
              fit: BoxFit.cover,
            ),
            error: (error, _) => Icon(
              Icons.error,
              size: size,
            ),
            loading: () => CircularProgressIndicator(),
          );
        }),
      ),
    );
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
      text: snapshot.getIfExists('text'),
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
      "text": text,
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
    String? text,
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
      text: text ?? this.text,
    );
  }
}

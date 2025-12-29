import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:greendayo/entity/article.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ulid/ulid.dart';

part 'article_repository.g.dart';

@riverpod
class ArticleRepository extends _$ArticleRepository {
  @override
  ArticleRepository build() {
    return this;
  }

  Stream<QuerySnapshot<Article>> observe() =>
      _articlesRef.orderBy('createdAt').limit(100).snapshots();

  Future<String> save(Article entity) async {
    final newDoc = _articlesRef.doc();
    await newDoc.set(entity);
    return newDoc.id;
  }

  Future<void> delete(String docId) async {
    final doc = _articlesRef.doc(docId);
    await doc.delete();
  }

  Future<String> uploadJpeg(Uint8List bytes) async {
    final storageRef = FirebaseStorage.instance.ref().child(
          'bbs/photo/${Ulid()}',
        );
    final uploadTask = storageRef.putData(
      bytes,
      SettableMetadata(
        contentType: "image/jpeg",
        cacheControl: 'public, max-age=315360000',
      ),
    );
    final result = await uploadTask;
    final url = await result.ref.getDownloadURL();
    return url;
  }
}

final _articlesRef =
    FirebaseFirestore.instance.collection('articles').withConverter<Article>(
          fromFirestore: (snapshot, _) => Article.fromSnapShot(snapshot),
          toFirestore: (article, _) => article.toJson(),
        );

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:greendayo/entity/article.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ulid/ulid.dart';

final articleRepository = Provider.autoDispose<ArticleRepository>((ref) => _ArticleRepositoryImpl(ref));

abstract class ArticleRepository {
  Stream<QuerySnapshot<Article>> observe();

  Future<String> save(Article entity);

  Future<void> delete(String docId);

  Future<String> uploadJpeg(Uint8List bytes);
}

final articlesRef = FirebaseFirestore.instance.collection('articles').withConverter<Article>(
      fromFirestore: (snapshot, _) => Article.fromSnapShot(snapshot),
      toFirestore: (article, _) => article.toJson(),
    );

class _ArticleRepositoryImpl implements ArticleRepository {
  final Ref ref;

  _ArticleRepositoryImpl(this.ref);

  @override
  Stream<QuerySnapshot<Article>> observe() => articlesRef.orderBy('createdAt').limit(100).snapshots();

  @override
  Future<String> save(Article entity) async {
    final newDoc = articlesRef.doc();
    await newDoc.set(entity);
    return newDoc.id;
  }

  @override
  Future<void> delete(String docId) async {
    final doc = articlesRef.doc(docId);
    await doc.delete();
  }

  @override
  Future<String> uploadJpeg(Uint8List bytes) async {
    final storageRef = FirebaseStorage.instance.ref().child('bbs/photo/${Ulid()}');
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

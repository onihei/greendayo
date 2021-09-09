import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/entity/article.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final articleRepository = Provider.autoDispose<ArticleRepository>(
    (ref) => _ArticleRepositoryImpl(ref.read));

abstract class ArticleRepository {
  Stream<QuerySnapshot<Article>> observe();

  Future<String> save(Article entity);
  Future<void> delete(String docId);
}

final articlesRef =
    FirebaseFirestore.instance.collection('articles').withConverter<Article>(
          fromFirestore: (snapshot, _) => Article.fromSnapShot(snapshot),
          toFirestore: (article, _) => article.toJson(),
        );

class _ArticleRepositoryImpl implements ArticleRepository {
  final Reader read;

  _ArticleRepositoryImpl(this.read);

  Stream<QuerySnapshot<Article>> observe() =>
      articlesRef.orderBy('createdAt').limit(100).snapshots();

  Future<String> save(Article entity) async {
    final newDoc = articlesRef.doc();
    await newDoc.set(entity);
    return newDoc.id;
  }

  Future<void> delete(String docId) async {
    final doc = articlesRef.doc(docId);
    await doc.delete();
  }
}

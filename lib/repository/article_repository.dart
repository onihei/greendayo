import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/entity/article.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final articleRepository = Provider.autoDispose<ArticleRepository>(
    (ref) => ArticleRepositoryImpl(ref.read));

abstract class ArticleRepository {
  Stream<QuerySnapshot<Article>> observe();

  Future<void> save(Article entity);
}

final articlesRef =
    FirebaseFirestore.instance.collection('articles').withConverter<Article>(
          fromFirestore: (snapshot, _) => Article.fromSnapShot(snapshot),
          toFirestore: (article, _) => article.toJson(),
        );

class ArticleRepositoryImpl implements ArticleRepository {
  final Reader read;

  ArticleRepositoryImpl(this.read);

  Stream<QuerySnapshot<Article>> observe() =>
      articlesRef.limit(100).snapshots();

  Future<void> save(Article entity) async {
    final newDoc = articlesRef.doc();
    await newDoc.set(entity);
  }
}

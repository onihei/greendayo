import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/entity/article.dart';
import 'package:greendayo/repository/article_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article.g.dart';

@riverpod
Stream<QuerySnapshot<Article>> articlesStream(ref) {
  return ref.read(articleRepositoryProvider).observe();
}

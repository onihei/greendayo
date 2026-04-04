import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/features/bbs/article.dart';
import 'package:greendayo/features/bbs/article_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_providers.g.dart';

@riverpod
Stream<QuerySnapshot<Article>> articlesStream(Ref ref) {
  return ref.read(articleRepositoryProvider).observe();
}

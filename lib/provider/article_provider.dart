import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/entity/article.dart';
import 'package:greendayo/repository/article_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final articlesStreamProvider =
    StreamProvider.autoDispose<QuerySnapshot<Article>>((ref) {
      return ref.read(articleRepository).observe();
    });

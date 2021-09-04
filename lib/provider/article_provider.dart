import 'package:greendayo/repository/article_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final articlesStreamProvider = StreamProvider.autoDispose((ref) {
  return ref.read(articleRepository).observe();
});

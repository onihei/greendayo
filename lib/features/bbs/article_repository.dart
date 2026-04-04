import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/features/bbs/article.dart';
import 'package:greendayo/shared/config.dart';
import 'package:greendayo/shared/exceptions/app_exception.dart';
import 'package:greendayo/shared/firebase/firebase_providers.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ulid/ulid.dart';

part 'article_repository.g.dart';

@riverpod
ArticleRepository articleRepository(Ref ref) => ArticleRepository(
      ref.read(firestoreProvider),
      ref.read(httpClientProvider),
    );

class ArticleRepository {
  final FirebaseFirestore _firestore;
  final http.Client _httpClient;

  ArticleRepository(this._firestore, this._httpClient);

  CollectionReference<Article> get _articlesRef =>
      _firestore.collection('articles').withConverter<Article>(
            fromFirestore: (snapshot, _) => Article.fromJson(
                {...snapshot.data()!, 'createdAt': snapshot.get('createdAt')}),
            toFirestore: (article, _) {
              final json = article.toJson();
              json['createdAt'] = Timestamp.fromDate(article.createdAt);
              return json;
            },
          );

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
    final storagePath = 'bbs/photo/${Ulid()}';
    final uri = Uri.parse('$storageBaseUrl/storage/upload/$storagePath');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'photo.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    final response = await _httpClient.send(request);
    if (response.statusCode != 200) {
      throw AppException(
          ErrorKind.server, 'アップロードに失敗しました: ${response.statusCode}');
    }
    return '$storageBaseUrl/storage/$storagePath';
  }
}

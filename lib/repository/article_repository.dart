import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/config.dart';
import 'package:greendayo/entity/article.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ulid/ulid.dart';

part 'article_repository.g.dart';

@riverpod
ArticleRepository articleRepository(Ref ref) => ArticleRepository();

class ArticleRepository {
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
    final response = await request.send();
    if (response.statusCode != 200) {
      throw StateError('Upload failed: ${response.statusCode}');
    }
    return '$storageBaseUrl/storage/$storagePath';
  }
}

final _articlesRef =
    FirebaseFirestore.instance.collection('articles').withConverter<Article>(
          fromFirestore: (snapshot, _) => Article.fromSnapShot(snapshot),
          toFirestore: (article, _) => article.toJson(),
        );

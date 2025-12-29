import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/entity/article.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ArticlePhoto extends ConsumerWidget {
  final Article article;
  const ArticlePhoto({super.key, required this.article});

  @override
  Widget build(context, ref) {
    if (!article.isPhoto) {
      return const SizedBox.shrink();
    }
    final pattern = RegExp('<img src="(.+)" data-rotation="(.+)"');
    final matches = pattern.allMatches(article.content);
    if (matches.isEmpty) {
      return const SizedBox.shrink();
    }
    final url = matches.single.group(1);
    if (url == null) {
      return const SizedBox.shrink();
    }
    return CachedNetworkImage(imageUrl: url, fit: BoxFit.cover);
  }
}

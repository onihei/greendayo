import 'dart:math';

import 'package:flutter/material.dart';
import 'package:greendayo/features/auth/user_provider.dart';
import 'package:greendayo/features/bbs/article.dart';
import 'package:greendayo/features/bbs/article_repository.dart';
import 'package:greendayo/features/bbs/bbs_form.dart';
import 'package:greendayo/features/profile/profile_providers.dart';
import 'package:greendayo/shared/utils/snackbars.dart';
import 'package:greendayo/shared/web/my_image_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bbs_controller.g.dart';

@riverpod
class BbsController extends _$BbsController {
  @override
  BbsController build() {
    return this;
  }

  void startCreate() {
    ref.read(bbsScaleProvider.notifier).setScale(1.0);
    ref.read(bbsFormEnabledProvider.notifier).setEnabled(true);
  }

  Future<void> post(
    BuildContext context, {
    required GlobalKey formContainerKey,
    required GlobalKey formKey,
  }) async {
    final myProfile = ref.read(myProfileProvider).requireValue;

    final stackBox =
        formContainerKey.currentContext?.findRenderObject() as RenderBox;
    final formBox = formKey.currentContext?.findRenderObject() as RenderBox;
    final positionStack = stackBox.localToGlobal(Offset.zero);
    final positionForm = formBox.localToGlobal(Offset.zero);
    final formOffset = Offset(
      positionForm.dx - positionStack.dx,
      positionForm.dy - positionStack.dy,
    );

    String text;
    final form = ref.read(bbsFormProvider);
    final screenOffset = ref.read(bbsOffsetProvider);

    if (form.isPhotoMode) {
      final url = await ref
          .read(articleRepositoryProvider)
          .uploadJpeg(form.photoJpgBytes!);
      text = '<img src="$url" data-rotation="${form.rotation}" />';
    } else {
      text = form.text;
      if (text.trim().isEmpty) {
        showSnackBar(
          context,
          content: Text('投稿内容を記入してください'),
        );
        return;
      }
    }
    final now = DateTime.now();
    final left = -screenOffset.dx + formOffset.dx;
    final top = -screenOffset.dy + formOffset.dy;
    final newArticle = Article(
      content: text,
      signature: myProfile.nickname,
      left: left,
      top: top,
      width: form.width,
      createdAt: now,
      createdBy: myProfile.userId,
    );
    final docId = await ref.read(articleRepositoryProvider).save(newArticle);
    ref.read(bbsFormEnabledProvider.notifier).setEnabled(false);
    ref.read(bbsFormProvider.notifier).changePhotoJpgBytes(null);

    showSnackBar(
      context,
      content: const Text('投稿しました'),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: '取消',
        onPressed: () async {
          await undo(context, docId: docId);
        },
      ),
    );
  }

  Future<void> undo(BuildContext context, {required String docId}) async {
    await ref.read(articleRepositoryProvider).delete(docId);
    showSnackBar(
      context,
      content: Text('投稿を取り消しました'),
      duration: Duration(seconds: 3),
    );
  }

  Future<void> deleteArticle(BuildContext context,
      {required String docId}) async {
    await ref.read(articleRepositoryProvider).delete(docId);
    showSnackBar(
      context,
      content: Text('削除しました'),
      duration: Duration(seconds: 3),
    );
  }

  Future<void> preparePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result == null) {
      return;
    }
    final mimeType = result.mimeType;
    if (mimeType == null) {
      showSnackBar(
        context,
        content: Text('ファイルの読み込みに失敗しました。'),
      );
      return;
    }
    final resultBytes = await result.readAsBytes();
    final tempImage = await decodeBytes(mimeType: mimeType, bytes: resultBytes);
    if (tempImage == null) {
      showSnackBar(
        context,
        content: Text('ファイルの読み込みに失敗しました。'),
      );
      return;
    }
    final resized = img.copyResize(tempImage, width: min(tempImage.width, 500));
    final bytes = img.encodeJpg(resized, quality: 80).buffer.asUint8List();
    ref.read(bbsFormProvider.notifier).changePhotoJpgBytes(bytes);
  }

  void showProfile(String userId) {
    ref.read(selectedUserIdProvider.notifier).select(userId);
  }
}

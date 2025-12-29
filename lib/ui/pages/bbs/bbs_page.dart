import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greendayo/domain/model/article.dart';
import 'package:greendayo/domain/model/profile.dart';
import 'package:greendayo/domain/model/user.dart';
import 'package:greendayo/entity/article.dart';
import 'package:greendayo/navigation_item_widget.dart';
import 'package:greendayo/repository/article_repository.dart';
import 'package:greendayo/ui/fragments/article_photo.dart';
import 'package:greendayo/ui/utils/snackbars.dart';
import 'package:greendayo/web/my_image_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bbs_page.g.dart';

@riverpod
class _ScreenOffset extends _$ScreenOffset {
  @override
  Offset build() {
    return Offset.zero;
  }

  void setOffset(Offset offset) {
    state = offset;
  }
}

@riverpod
class _ScreenScale extends _$ScreenScale {
  @override
  double build() {
    return 1.0;
  }

  void setScale(double scale) {
    state = scale;
  }
}

@riverpod
class _FormEnabled extends _$FormEnabled {
  @override
  bool build() {
    return false;
  }

  void setEnabled(bool enabled) {
    state = enabled;
  }
}

class _BbsFormState {
  final String text;
  final double width;
  final Uint8List? photoJpgBytes;
  final double rotation;

  const _BbsFormState({
    this.text = '',
    this.width = 200,
    this.photoJpgBytes,
    this.rotation = 0.0,
  });

  bool get isPhotoMode => photoJpgBytes != null;

  Image? get photo {
    final bytes = photoJpgBytes;
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }
    return null;
  }

  _BbsFormState copyWith({
    String? text,
    double? width,
    double? rotation,
  }) {
    return _BbsFormState(
      text: text ?? this.text,
      width: width ?? this.width,
      photoJpgBytes: this.photoJpgBytes,
      rotation: rotation ?? this.rotation,
    );
  }

  _BbsFormState copyWithPhotoJpgBytes(Uint8List? bytes) {
    return _BbsFormState(
      text: text,
      width: width,
      photoJpgBytes: bytes,
      rotation: rotation,
    );
  }
}

// Notifier
@riverpod
class _BbsForm extends _$BbsForm {
  @override
  _BbsFormState build() => const _BbsFormState();

  void changeText(String newText) {
    state = state.copyWith(text: newText);
  }

  void changePhotoJpgBytes(Uint8List? bytes) {
    final newState = state.copyWithPhotoJpgBytes(bytes);
    state = newState.copyWith(rotation: _randomRotation());
  }

  void shake() {
    if (!state.isPhotoMode) return;
    state = state.copyWith(rotation: _randomRotation());
  }

  void clear() {
    state = const _BbsFormState();
  }

  double _randomRotation() {
    double u1 = 0;
    double u2 = 0;
    while (u1 == 0) {
      u1 = Random().nextDouble();
    }
    while (u2 == 0) {
      u2 = Random().nextDouble();
    }
    final r = sqrt(-2.0 * log(u1)) * cos(2 * pi * u2);
    return (2.71828 - r.abs()) * (Random().nextBool() ? 1 : -1) / 8;
  }
}

@riverpod
class _ViewController extends _$ViewController {
  final formContainerKey = GlobalKey();
  final formKey = GlobalKey();
  double scaleStarted = 1.0;
  Offset offsetStarted = Offset.zero;

  @override
  _ViewController build() {
    return this;
  }

  void startCreate() {
    ref.read(_screenScaleProvider.notifier).setScale(1.0);
    ref.read(_formEnabledProvider.notifier).setEnabled(true);
  }

  Future<void> post(BuildContext context) async {
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
    final form = ref.read(_bbsFormProvider);
    final screenOffset = ref.read(_screenOffsetProvider);

    if (form.isPhotoMode) {
      final url = await ref
          .read(articleRepositoryProvider)
          .uploadJpeg(form.photoJpgBytes!);
      text = '<img src="$url" data-rotation="${form.rotation}" />';
    } else {
      text = form.text ?? "";
      if (text.trim().isEmpty) {
        showSnackBar(
          context,
          ref,
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
    ref.read(_formEnabledProvider.notifier).setEnabled(false);
    ref.read(_bbsFormProvider.notifier).changePhotoJpgBytes(null);

    showSnackBar(
      context,
      ref,
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
      ref,
      content: Text('投稿を取り消しました'),
      duration: Duration(seconds: 3),
    );
  }

  Future<void> deleteArticle(BuildContext context,
      {required String docId}) async {
    await ref.read(articleRepositoryProvider).delete(docId);
    showSnackBar(
      context,
      ref,
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
        ref,
        content: Text('ファイルの読み込みに失敗しました。'),
      );
      return;
    }
    final resultBytes = await result.readAsBytes();
    final tempImage = await decodeBytes(mimeType: mimeType, bytes: resultBytes);
    if (tempImage == null) {
      showSnackBar(
        context,
        ref,
        content: Text('ファイルの読み込みに失敗しました。'),
      );
      return;
    }
    final resized = img.copyResize(tempImage, width: min(tempImage.width, 500));
    final bytes = img.encodeJpg(resized, quality: 80).buffer.asUint8List();
    ref.read(_bbsFormProvider.notifier).changePhotoJpgBytes(bytes);
  }

  void showProfile(String userId) {
    ref.read(selectedUserIdProvider.notifier).select(userId);
  }
}

class BbsPage extends HookConsumerWidget implements NavigationItemWidget {
  const BbsPage({super.key});

  @override
  String get title => '掲示板';

  @override
  Widget? get floatingActionButton => Consumer(
        builder: (context, ref, child) {
          final enabled = ref.watch(_formEnabledProvider);
          final button = FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              ref.read(_viewControllerProvider).startCreate();
            },
          );
          return Visibility(visible: !enabled, child: button);
        },
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(articlesStreamProvider);
    return result.maybeWhen(
      data: (value) => _buildScreen(context, ref),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildScreen(
    BuildContext context,
    WidgetRef ref,
  ) {
    final vc = ref.watch(_viewControllerProvider);
    final formEnabled = ref.watch(_formEnabledProvider);
    ref.watch(_bbsFormProvider);
    return Stack(
      key: vc.formContainerKey,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _buildBoard(context, ref),
        if (formEnabled) ...[
          Align(
            alignment: const Alignment(0, -0.2),
            child: _buildForm(context, ref),
          ),
          _buildEditActions(context, ref),
        ],
      ],
    );
  }

  Widget _buildBoard(
    BuildContext context,
    WidgetRef ref,
  ) {
    final snapshot = ref.watch(articlesStreamProvider).requireValue;
    final papers = snapshot.docs.map((articleDoc) {
      final article = articleDoc.data();
      return Consumer(builder: (context, ref, child) {
        final screenOffset = ref.watch(_screenOffsetProvider);
        return Positioned(
          left: screenOffset.dx + article.left.toDouble(),
          top: screenOffset.dy + article.top.toDouble(),
          child: _articleCard(context, ref, articleDoc),
        );
      });
    }).toList();
    final panStarted = useRef<Offset?>(null);
    final scaleStarted = useRef<double>(1.0);
    final gestureDetector = GestureDetector(
      onScaleStart: (detail) {
        panStarted.value = ref.read(_screenOffsetProvider);
        scaleStarted.value = ref.read(_screenScaleProvider);
      },
      onScaleUpdate: (details) {
        final panStartedValue = panStarted.value;
        if (panStartedValue == null) {
          return;
        }
        if (details.pointerCount == 1) {
          final offset = ref.read(_screenOffsetProvider);
          ref.read(_screenOffsetProvider.notifier).setOffset(offset.translate(
                details.focalPointDelta.dx / scaleStarted.value,
                details.focalPointDelta.dy / scaleStarted.value,
              ));
        } else {
          final newScale = scaleStarted.value * details.scale;
          ref.read(_screenOffsetProvider.notifier).setOffset(panStartedValue);
          ref.read(_screenScaleProvider.notifier).setScale(newScale);
        }
      },
      onScaleEnd: (details) {
        panStarted.value = null;
        ref.read(_bbsFormProvider.notifier).shake();
      },
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Consumer(builder: (context, ref, child) {
          final scale = ref.watch(_screenScaleProvider);
          return Transform.scale(
            scale: scale,
            child: Stack(clipBehavior: Clip.none, children: papers),
          );
        }),
      ),
    );
    return gestureDetector;
  }

  Widget _articleCard(
    BuildContext context,
    WidgetRef ref,
    QueryDocumentSnapshot<Article> snapShot,
  ) {
    final vc = ref.watch(_viewControllerProvider);
    final article = snapShot.data();
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      onSelected: (s) async {
        if (s == "profile") {
          vc.showProfile(article.createdBy);
        }
        if (s == "delete") {
          await vc.deleteArticle(context, docId: snapShot.id);
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(value: "profile", child: Text("プロフィールを見る")),
          const PopupMenuItem(value: "delete", child: Text("削除する")),
        ];
      },
      child: article.isPhoto
          ? _photoContent(context, ref, article)
          : _textContent(context, ref, article),
    );
  }

  Widget _photoContent(BuildContext context, WidgetRef ref, Article article) {
    final content = Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      width: article.width.toDouble(),
      height: article.width.toDouble() + 16,
      decoration: _photoBoxDecoration(context),
      child: ArticlePhoto(article: article),
    );
    final rotation = article.rotation ?? 0;
    return Transform.rotate(angle: rotation, child: content);
  }

  Widget _textContent(BuildContext context, WidgetRef ref, Article article) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: article.width.toDouble(),
      decoration: _textBoxDecoration(
        context,
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(article.content),
          Row(children: [const Spacer(), Text(article.signature)]),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_bbsFormProvider);
    if (form.isPhotoMode) {
      return _photoForm(context, ref);
    } else {
      return _textForm(context, ref);
    }
  }

  Widget _photoForm(BuildContext context, WidgetRef ref) {
    final vc = ref.watch(_viewControllerProvider);
    final form = ref.watch(_bbsFormProvider);
    final content = Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      width: form.width,
      height: form.width + 16,
      decoration: _photoBoxDecoration(context),
      child: form.photo,
    );
    return Container(
      key: vc.formKey,
      child: Transform.rotate(angle: form.rotation, child: content),
    );
  }

  Widget _textForm(BuildContext context, WidgetRef ref) {
    final vc = ref.watch(_viewControllerProvider);
    final form = ref.watch(_bbsFormProvider);
    final controller = useTextEditingController();
    final myProfile = ref.watch(myProfileProvider).requireValue;
    return Container(
      key: vc.formKey,
      padding: const EdgeInsets.all(4),
      width: form.width,
      decoration: _textBoxDecoration(
        context,
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        maxLength: 200,
        onChanged: (input) {
          ref.read(_bbsFormProvider.notifier).changeText(input);
        },
        textInputAction: TextInputAction.newline,
        buildCounter:
            (_, {required currentLength, maxLength, required isFocused}) => Row(
          children: [
            Text('$currentLength / $maxLength'),
            const Spacer(),
            Text(myProfile.nickname),
          ],
        ),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: const EdgeInsets.all(10),
          fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
          errorText: null,
          hintText: '投稿内容をここに書いてください。',
          hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildEditActions(BuildContext context, WidgetRef ref) {
    final vc = ref.watch(_viewControllerProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Row(
          children: [
            const Spacer(),
            IconButton(
              onPressed: () async {
                await vc.preparePhoto(context);
              },
              icon: const Icon(Icons.photo),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () async {
                await vc.post(context);
              },
              child: const Text('投稿する'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () async {
                ref.read(_bbsFormProvider.notifier).changePhotoJpgBytes(null);
                ref.read(_formEnabledProvider.notifier).setEnabled(false);
              },
              child: const Text('キャンセル'),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _textBoxDecoration(context, {required Color color}) {
    return BoxDecoration(
      color: color,
      boxShadow: [
        BoxShadow(
          color: color,
          spreadRadius: 1.2,
          blurRadius: 1,
          offset: const Offset(1, 1),
        ),
      ],
    );
  }

  BoxDecoration _photoBoxDecoration(context) {
    return BoxDecoration(
      color: Colors.white,
      gradient: LinearGradient(
        begin: FractionalOffset.topCenter,
        end: FractionalOffset.bottomCenter,
        colors: [Colors.white, Colors.grey[200]!],
        stops: const [0.0, 1.0],
      ),
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.5),
          spreadRadius: 0,
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/entity/article.dart';
import 'package:greendayo/provider/article_provider.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/repository/article_repository.dart';
import 'package:greendayo/tab_config.dart';
import 'package:greendayo/web/my_image_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

final _boardWidthProvider = StateProvider.autoDispose<double>((ref) => 0.0);
final _boardHeightProvider = StateProvider.autoDispose<double>((ref) => 0.0);

final _screenScaleProvider = StateProvider.autoDispose<double>((ref) => 1.0);
final _screenOffsetProvider = StateProvider.autoDispose<Offset>((ref) => Offset.zero);

final _editProvider = StateProvider.autoDispose<bool>((ref) => false);

final _loadingProvider = StateProvider<bool>((ref) => false);

class _FormNotifier extends StateNotifier<BbsForm> {
  _FormNotifier() : super(const BbsForm());

  void changeText(String text) {
    state = state.copyWith(text: text);
  }

  void changePhotoJpgBytes(Uint8List bytes) {
    state = state.copyWith(
      photoJpgBytes: bytes,
      rotation: _randomRotation(),
      width: 200,
    );
  }

  void shake() {
    if (!state.isPhotoMode) {
      return;
    }
    state = state.copyWith(
      rotation: _randomRotation(),
    );
  }

  void clear() {
    state = const BbsForm();
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

final _formProvider = StateNotifierProvider.autoDispose<_FormNotifier, BbsForm>((ref) {
  return _FormNotifier();
});

class BbsForm {
  const BbsForm({this.text, this.photoJpgBytes, this.rotation = 0, this.width = 270});

  final String? text;
  final double width;
  final Uint8List? photoJpgBytes;
  final double rotation;

  Image? get photo {
    final bytes = photoJpgBytes;
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }
    return null;
  }

  bool get isPhotoMode {
    return photoJpgBytes != null;
  }

  BbsForm copyWith({String? text, Uint8List? photoJpgBytes, double? rotation, double? width}) {
    return BbsForm(
      text: text ?? this.text,
      photoJpgBytes: photoJpgBytes ?? this.photoJpgBytes,
      rotation: rotation ?? this.rotation,
      width: width ?? this.width,
    );
  }
}

class BbsTabConfig implements TabConfig {
  @override
  String get label => '掲示板';

  @override
  Widget get icon => const Icon(Icons.forum_outlined);

  @override
  Widget get activeIcon => const Icon(Icons.forum);

  @override
  Function get factoryMethod => BbsPage.new;

  @override
  Widget get floatingActionButton => Consumer(
        builder: (context, ref, child) {
          final edit = ref.watch(_editProvider);
          final button = FloatingActionButton(
            child: const Icon(
              Icons.add,
            ),
            onPressed: () {
              ref.read(_bbsViewController).startCreate();
            },
          );
          return Visibility(
            visible: !edit,
            child: button,
          );
        },
      );
}

final _bbsViewController = Provider<_BbsViewController>((ref) => _BbsViewController(ref));

class _BbsViewController {
  final Ref ref;
  double scaleStarted = 1.0;
  Offset offsetStarted = Offset.zero;

  _BbsViewController(this.ref);

  void onScaleStart(ScaleStartDetails details) {
    scaleStarted = ref.read(_screenScaleProvider);
    offsetStarted = ref.read(_screenOffsetProvider);
  }

  void onScaleEnd(ScaleEndDetails details) {
    ref.read(_formProvider.notifier).shake();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 1) {
      final offset = ref.read(_screenOffsetProvider.notifier).state;
      ref.read(_screenOffsetProvider.notifier).state =
          offset.translate(details.focalPointDelta.dx, details.focalPointDelta.dy);
    } else {
      final newScale = scaleStarted * details.scale;
      final width = ref.read(_boardWidthProvider);
      final height = ref.read(_boardHeightProvider);
      final local = Offset((-(details.focalPointDelta.dx + width / 2) * (details.scale - 1)),
          (-(details.focalPointDelta.dy + height / 2) * (details.scale - 1)));
      final newOffset = local.translate(offsetStarted.dx * details.scale, offsetStarted.dy * details.scale);
      ref.read(_screenOffsetProvider.notifier).state = newOffset;
      ref.read(_screenScaleProvider.notifier).state = newScale;
    }
  }

  void startCreate() {
    ref.read(_screenScaleProvider.notifier).state = 1.0;
    ref.read(_editProvider.notifier).state = true;
  }

  Future<void> post() async {
    final myProfile = ref.read(myProfileProvider);

    final keyFormContainer = ref.read(globalKeyProvider("formContainer"));
    final keyForm = ref.read(globalKeyProvider("form"));
    final stackBox = keyFormContainer.currentContext?.findRenderObject() as RenderBox;
    final formBox = keyForm.currentContext?.findRenderObject() as RenderBox;
    final positionStack = stackBox.localToGlobal(Offset.zero);
    final positionForm = formBox.localToGlobal(Offset.zero);
    final formOffset = Offset(positionForm.dx - positionStack.dx, positionForm.dy - positionStack.dy);

    String text;
    final form = ref.read(_formProvider);
    final screenOffset = ref.read(_screenOffsetProvider);

    if (form.isPhotoMode) {
      final url = await ref.read(articleRepository).uploadJpeg(form.photoJpgBytes!);
      text = '<img src="$url" data-rotation="${form.rotation}" />';
    } else {
      text = form.text ?? "";
      if (text.trim().isEmpty) {
        ref.read(snackBarController)?.showSnackBar(
              const SnackBar(
                content: Text('投稿内容を記入してください'),
                duration: Duration(seconds: 3),
              ),
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
    final docId = await ref.read(articleRepository).save(newArticle);
    ref.read(_editProvider.notifier).state = false;

    ref.read(snackBarController)?.showSnackBar(
          SnackBar(
            content: const Text('投稿しました'),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: '取消',
              onPressed: () async {
                await undo(docId);
              },
            ),
          ),
        );
  }

  Future<void> undo(String docId) async {
    await ref.read(articleRepository).delete(docId);
    ref.read(snackBarController)?.showSnackBar(
          const SnackBar(
            content: Text('投稿を取り消しました'),
            duration: Duration(seconds: 3),
          ),
        );
  }

  Future<void> deleteArticle({required String docId}) async {
    await ref.read(articleRepository).delete(docId);
  }

  Future<void> preparePhoto() async {
    final snackBar = ref.read(snackBarController);
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result == null) {
      return;
    }
    final mimeType = result.mimeType;
    if (mimeType == null) {
      snackBar?.showSnackBar(
        const SnackBar(
          content: Text('ファイルの読み込みに失敗しました。'),
        ),
      );
      return;
    }
    ref.read(_loadingProvider.notifier).state = true;
    final resultBytes = await result.readAsBytes();
    final tempImage = await decodeBytes(mimeType: mimeType, bytes: resultBytes);
    if (tempImage == null) {
      ref.read(_loadingProvider.notifier).state = false;
      snackBar?.showSnackBar(
        const SnackBar(
          content: Text('ファイルの読み込みに失敗しました。'),
        ),
      );
      return;
    }
    final resized = img.copyResize(tempImage, width: min(tempImage.width, 500));
    final bytes = img.encodeJpg(resized, quality: 80).buffer.asUint8List();
    ref.read(_formProvider.notifier).changePhotoJpgBytes(bytes);
    ref.read(_loadingProvider.notifier).state = false;
  }
}

class BbsPage extends HookConsumerWidget {
  const BbsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(articlesStreamProvider);
    return result.maybeWhen(
      data: (value) => _buildScreen(context, ref, value),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildScreen(BuildContext context, WidgetRef ref, QuerySnapshot<Article> snapshot) {
    final edit = ref.watch(_editProvider);
    final keyFormContainer = ref.watch(globalKeyProvider("formContainer"));

    return Stack(
      key: keyFormContainer,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraint) {
            Future.microtask(() {
              ref.watch(_boardWidthProvider.notifier).state = constraint.maxWidth;
              ref.watch(_boardHeightProvider.notifier).state = constraint.maxHeight;
            });
            return _buildBoard(context, ref, snapshot);
          },
        ),
        if (edit)
          Align(
            alignment: const Alignment(0, -0.2),
            child: _buildForm(context, ref),
          ),
        if (edit) _buildEditActions(context, ref),
      ],
    );
  }

  Widget _buildBoard(BuildContext context, WidgetRef ref, QuerySnapshot<Article> snapshot) {
    final offset = ref.watch(_screenOffsetProvider);
    final scale = ref.watch(_screenScaleProvider);

    final papers = snapshot.docs.map((articleDoc) {
      final article = articleDoc.data();
      return Positioned(
        left: article.left.toDouble(),
        top: article.top.toDouble(),
        child: _articleCard(context, ref, articleDoc),
      );
    }).toList();
    return GestureDetector(
      onScaleStart: ref.read(_bbsViewController).onScaleStart,
      onScaleEnd: ref.read(_bbsViewController).onScaleEnd,
      onScaleUpdate: ref.read(_bbsViewController).onScaleUpdate,
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Transform(
          transform: Matrix4.identity()
            ..translate(offset.dx, offset.dy)
            ..scale(scale, scale, 1),
          child: Stack(
            clipBehavior: Clip.none,
            children: papers,
          ),
        ),
      ),
    );
  }

  Widget _articleCard(BuildContext context, WidgetRef ref, QueryDocumentSnapshot<Article> snapShot) {
    final article = snapShot.data();
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      onSelected: (s) async {
        if (s == "profile") {
          await Navigator.pushNamed(context, "/profile", arguments: article.createdBy);
        }
        if (s == "delete") {
          await ref.read(_bbsViewController).deleteArticle(docId: snapShot.id);
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(
            value: "profile",
            child: Text("プロフィールを見る"),
          ),
          const PopupMenuItem(
            value: "delete",
            child: Text("削除する"),
          ),
        ];
      },
      child: article.isPhoto ? _photoContent(context, ref, article) : _textContent(context, ref, article),
    );
  }

  Widget _photoContent(BuildContext context, WidgetRef ref, Article article) {
    final content = Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      width: article.width.toDouble(),
      height: article.width.toDouble() + 16,
      decoration: _photoBoxDecoration(context),
      child: article.photoImage,
    );
    final rotation = article.rotation ?? 0;
    return Container(
      child: Transform.rotate(
        angle: rotation,
        child: content,
      ),
    );
  }

  Widget _textContent(BuildContext context, WidgetRef ref, Article article) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: article.width.toDouble(),
      decoration: _textBoxDecoration(context, color: Theme.of(context).colorScheme.primaryContainer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(article.content),
          Row(
            children: [
              const Spacer(),
              Text(article.signature),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(_loadingProvider);
    final form = ref.watch(_formProvider);
    if (loading) {
      return const SizedBox.shrink();
    }
    if (form.isPhotoMode) {
      return _photoForm(context, ref);
    } else {
      return _textForm(context, ref);
    }
  }

  Widget _photoForm(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final keyForm = ref.watch(globalKeyProvider("form"));

    final content = Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      width: form.width,
      height: form.width + 16,
      decoration: _photoBoxDecoration(context),
      child: form.photo,
    );
    return Container(
      key: keyForm,
      child: Transform.rotate(
        angle: form.rotation,
        child: content,
      ),
    );
  }

  Widget _textForm(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final controller = ref.watch(textEditingControllerProvider("BbsForm"));
    controller.value = controller.value.copyWith(text: form.text);
    final keyForm = ref.watch(globalKeyProvider("form"));
    final myProfile = ref.watch(myProfileProvider);

    return Container(
      key: keyForm,
      padding: const EdgeInsets.all(4),
      width: form.width,
      decoration: _textBoxDecoration(context, color: Theme.of(context).colorScheme.secondaryContainer),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        maxLength: 200,
        onChanged: (input) {
          ref.read(_formProvider.notifier).changeText(input);
        },
        textInputAction: TextInputAction.newline,
        buildCounter: (_, {required currentLength, maxLength, required isFocused}) => Row(
          children: [
            Text('$currentLength / $maxLength'),
            const Spacer(),
            Text(myProfile.nickname),
          ],
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: const EdgeInsets.all(10),
          fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
          errorText: null,
          hintText: '投稿内容をここに書いてください。',
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildEditActions(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Row(
          children: [
            const Spacer(),
            IconButton(
              onPressed: () async {
                await ref.read(_bbsViewController).preparePhoto();
              },
              icon: const Icon(Icons.photo),
            ),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(_bbsViewController).post();
              },
              child: const Text('投稿する'),
            ),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                ref.read(_editProvider.notifier).state = false;
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
        colors: [
          Colors.white,
          Colors.grey[200]!,
        ],
        stops: const [
          0.0,
          1.0,
        ],
      ),
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.2),
          spreadRadius: 0,
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

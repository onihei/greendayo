import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greendayo/entity/article.dart';
import 'package:greendayo/provider/article_provider.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/repository/article_repository.dart';
import 'package:greendayo/tab_config.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _screenOffsetProvider = StateProvider.autoDispose<Offset>((ref) => Offset.zero);

final _editProvider = StateProvider.autoDispose<bool>((ref) => false);

class _FormNotifier extends StateNotifier<BbsForm> {
  _FormNotifier() : super(BbsForm(text: ""));

  void changeText(String text) {
    state = state.copyWith(text: text);
  }

  void clear() {
    state = BbsForm(text: "");
  }
}

final _formProvider = StateNotifierProvider.autoDispose<_FormNotifier, BbsForm>((ref) {
  return _FormNotifier();
});

class BbsForm {
  const BbsForm({required this.text});

  final String text;

  BbsForm copyWith({String? text}) {
    return BbsForm(
      text: text ?? this.text,
    );
  }
}

final _formWidthProvider = StateProvider.autoDispose<double>((ref) => 270);

class BbsTabConfig implements TabConfig {
  @override
  String get label => '掲示板';

  @override
  Widget get icon => Icon(Icons.forum_outlined);

  @override
  Widget get activeIcon => Icon(Icons.forum);

  @override
  Function get factoryMethod => BbsPage.new;

  @override
  Widget get floatingActionButton => Consumer(
        builder: (context, ref, child) {
          final edit = ref.watch(_editProvider);
          final button = FloatingActionButton(
            child: Icon(
              Icons.add,
            ),
            onPressed: () {
              ref.watch(_bbsViewController).startCreate();
            },
          );
          return Visibility(
            visible: !edit,
            child: button,
          );
        },
      );
}

class BbsPage extends HookConsumerWidget {
  const BbsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(articlesStreamProvider);
    return result.when(
        data: (value) => _buildScreen(context, ref, value),
        loading: () => Center(
              child: Text('loading'),
            ),
        error: (error, stackTrace) => Center(
              child: Text('error'),
            ));
  }

  Widget _buildScreen(BuildContext context, WidgetRef ref, QuerySnapshot<Article> snapshot) {
    final edit = ref.watch(_editProvider);
    final keyFormContainer = ref.watch(globalKeyProvider("formContainer"));

    return Stack(
      key: keyFormContainer,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _buildBoard(context, ref, snapshot),
        if (edit)
          Align(
            alignment: Alignment(0, -0.2),
            child: _buildForm(context, ref),
          ),
        if (edit) _buildEditActions(ref),
      ],
    );
  }

  Widget _buildBoard(BuildContext context, WidgetRef ref, QuerySnapshot<Article> snapshot) {
    final screenOffset = ref.watch(_screenOffsetProvider);

    final papers = snapshot.docs.map((articleDoc) {
      final article = articleDoc.data();
      return Positioned(
        left: screenOffset.dx + article.left.toDouble(),
        top: screenOffset.dy + article.top.toDouble(),
        child: _articleCard(context, ref, articleDoc),
      );
    }).toList();
    return GestureDetector(
      onPanUpdate: ref.read(_bbsViewController).pan,
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Stack(
          children: papers,
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
      child: Container(
        padding: EdgeInsets.all(10),
        width: article.width.toDouble(),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 1.2,
              blurRadius: 1,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.text),
            Row(
              children: [
                Spacer(),
                Text(article.signature),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final formWidth = ref.watch(_formWidthProvider);
    final controller = ref.watch(textEditingControllerProvider("BbsForm"));
    controller.value = controller.value.copyWith(text: form.text);
    final keyForm = ref.watch(globalKeyProvider("form"));
    final myProfile = ref.watch(myProfileProvider);

    return Container(
      key: keyForm,
      padding: EdgeInsets.all(4),
      width: formWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1.2,
            blurRadius: 1,
            offset: Offset(1, 1),
          ),
        ],
      ),
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
            Spacer(),
            Text(myProfile.nickname),
          ],
        ),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: EdgeInsets.all(10),
          fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
          errorText: null,
          hintText: '投稿内容をここに書いてください。',
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildEditActions(WidgetRef ref) {
    final context = useContext();
    return Padding(
      padding: EdgeInsets.only(top: 32),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Row(
          children: [
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                await ref.read(_bbsViewController).post();
              },
              child: Text('投稿する'),
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                ref.read(_editProvider.notifier).state = false;
              },
              child: Text('キャンセル'),
            ),
          ],
        ),
      ),
    );
  }
}

final _bbsViewController = Provider.autoDispose<_BbsViewController>((ref) => _BbsViewController(ref));

class _BbsViewController {
  final Ref ref;

  _BbsViewController(this.ref);

  void pan(DragUpdateDetails details) {
    final offset = ref.read(_screenOffsetProvider.notifier).state;
    ref.read(_screenOffsetProvider.notifier).state = offset.translate(details.delta.dx, details.delta.dy);
  }

  void startCreate() {
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
    final formWidth = ref.read(_formWidthProvider);

    final text = ref.read(_formProvider).text;
    final screenOffset = ref.read(_screenOffsetProvider);
    if (text.trim().isEmpty) {
      ref.read(snackBarController)?.showSnackBar(
            SnackBar(
              content: Text('投稿内容を記入してください'),
              duration: const Duration(seconds: 3),
            ),
          );
      return;
    }
    final now = DateTime.now();
    final left = -screenOffset.dx + formOffset.dx;
    final top = -screenOffset.dy + formOffset.dy;
    final newArticle = Article(
      text: text,
      signature: myProfile.nickname,
      left: left,
      top: top,
      width: formWidth,
      createdAt: now,
      createdBy: myProfile.userId,
    );
    final docId = await ref.read(articleRepository).save(newArticle);
    ref.read(_editProvider.notifier).state = false;

    ref.read(snackBarController)?.showSnackBar(
          SnackBar(
            content: Text('投稿しました'),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: '取消',
              onPressed: () async {
                await this.undo(docId);
              },
            ),
          ),
        );
  }

  Future<void> undo(String docId) async {
    await ref.read(articleRepository).delete(docId);
    ref.read(snackBarController)?.showSnackBar(
          SnackBar(
            content: Text('投稿を取り消しました'),
            duration: const Duration(seconds: 3),
          ),
        );
  }

  Future<void> deleteArticle({required String docId}) async {
    await ref.read(articleRepository).delete(docId);
  }
}

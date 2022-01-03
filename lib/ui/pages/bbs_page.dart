import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greendayo/entity/article.dart';
import 'package:greendayo/my_app.dart';
import 'package:greendayo/provider/article_provider.dart';
import 'package:greendayo/repository/article_repository.dart';
import 'package:greendayo/tab_config.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _offsetProvider = StateProvider.autoDispose<Offset>((ref) => Offset.zero);

final _editProvider = StateProvider.autoDispose<bool>((ref) => false);

final _formProvider = StateProvider.autoDispose<BbsForm>((ref) => BbsForm());

class BbsForm {
  String text = '';
}

class BbsTabConfig implements TabConfig {
  @override
  String get label => '掲示板';

  @override
  Widget get icon => Icon(Icons.dangerous_sharp, color: Colors.red);

  @override
  Widget get activeIcon => Icon(Icons.dangerous_sharp);

  @override
  Function get factoryMethod => BbsPage.factoryMethod;

  @override
  Widget get floatingActionButton => Consumer(
        builder: (context, ref, child) {
          final edit = ref.watch(_editProvider);
          final button = FloatingActionButton(
            child: Icon(
              Icons.android,
            ),
            onPressed: () {
              ref.watch(_bbsViewModel).startCreate();
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
  final _keyStack = GlobalKey();
  final _keyForm = GlobalKey();

  static BbsPage factoryMethod() {
    return BbsPage();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(articlesStreamProvider);
    return result.when(
        data: (value) => _buildScreen(value, ref),
        loading: () => Center(
              child: Text('loading'),
            ),
        error: (error, stackTrace) => Center(
              child: Text('error'),
            ));
  }

  Widget _buildScreen(QuerySnapshot<Article> snapshot, WidgetRef ref) {
    final edit = ref.watch(_editProvider);

    return Stack(
      key: _keyStack,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _buildBoard(snapshot, ref),
        if (edit)
          Positioned(
            top: 20,
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildForm(ref),
            ),
          ),
        if (edit) _buildTools(ref),
      ],
    );
  }

  Widget _buildBoard(QuerySnapshot<Article> snapshot, WidgetRef ref) {
    final offset = ref.watch(_offsetProvider);

    final papers = snapshot.docs.map((noticeDoc) {
      final notice = noticeDoc.data();
      return Positioned(
          left: offset.dx + notice.left.toDouble(),
          top: offset.dy + notice.top.toDouble(),
          child: Container(
            padding: EdgeInsets.all(4),
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notice.text),
                Row(
                  children: [
                    Spacer(),
                    Text('みつを'),
                  ],
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.yellow,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 1.2,
                  blurRadius: 1,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ));
    }).toList();
    return GestureDetector(
      onPanUpdate: ref.read(_bbsViewModel).pan,
      child: Container(
        color: Colors.deepPurple,
        child: Stack(
          children: papers,
        ),
      ),
    );
  }

  Widget _buildForm(WidgetRef ref) {
    final context = useContext();
    final form = ref.watch(_formProvider);
    final controller = TextEditingController();
    controller.text = form.text;

    return Container(
      key: _keyForm,
      padding: EdgeInsets.all(4),
      width: 140,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        maxLength: 200,
        onChanged: (input) {
          ref.read(_formProvider.notifier).state.text = input;
        },
        textInputAction: TextInputAction.newline,
        buildCounter:
            (_, {required currentLength, maxLength, required isFocused}) => Row(
          children: [
            Text('$currentLength / $maxLength'),
            Spacer(),
            Text('みつを'),
          ],
        ),
        style: TextStyle(
          fontSize: 14,
          color: Colors.black54,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: EdgeInsets.all(0),
          fillColor: Colors.white38,
          errorText: null,
          hintText: '投稿内容',
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.yellow,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1.2,
            blurRadius: 1,
            offset: Offset(1, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTools(WidgetRef ref) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 32),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            color: Colors.cyan,
            child: Row(
              children: [
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final stackBox = _keyStack.currentContext
                        ?.findRenderObject() as RenderBox;
                    final formBox = _keyForm.currentContext?.findRenderObject()
                        as RenderBox;
                    final positionStack = stackBox.localToGlobal(Offset.zero);
                    final positionForm = formBox.localToGlobal(Offset.zero);
                    final offset = Offset(positionForm.dx - positionStack.dx,
                        positionForm.dy - positionStack.dy);
                    await ref.read(_bbsViewModel).post(offset);
                  },
                  child: Text('投稿'),
                ),
              ],
            ),
          ),
        ),
        ElevatedButton(
          child: Icon(Icons.clear),
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            onPrimary: Colors.black,
            shape: const CircleBorder(
              side: BorderSide(
                color: Colors.black,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
          ),
          onPressed: () {
            ref.read(_editProvider.notifier).state = false;
          },
        ),
      ],
    );
  }
}

final _bbsViewModel = Provider.autoDispose((ref) => _BbsViewModel(ref.read));

class _BbsViewModel {
  final Reader read;

  _BbsViewModel(this.read);

  void pan(DragUpdateDetails details) {
    final offset = read(_offsetProvider.notifier).state;
    read(_offsetProvider.notifier).state =
        offset.translate(details.delta.dx, details.delta.dy);
  }

  void startCreate() {
    read(_editProvider.notifier).state = true;
  }

  Future<void> post(Offset formOffset) async {
    final text = read(_formProvider).text;
    final offset = read(_offsetProvider);
    if (text.trim().isEmpty) {
      read(snackBarController)?.showSnackBar(
        SnackBar(
          content: Text('投稿内容を記入してください'),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    final now = DateTime.now();
    final left = -offset.dx + formOffset.dx;
    final top = -offset.dy + formOffset.dy;
    final newArticle = Article(text, left, top, now, 'me');
    final docId = await read(articleRepository).save(newArticle);
    read(_editProvider.notifier).state = false;

    read(snackBarController)?.showSnackBar(
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
    await read(articleRepository).delete(docId);
    read(snackBarController)?.showSnackBar(
      SnackBar(
        content: Text('投稿を取り消しました'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

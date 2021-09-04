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
        builder: (context, watch, child) {
          final edit = watch(_editProvider).state;
          final button = FloatingActionButton(
            child: Icon(
              Icons.android,
            ),
            onPressed: () {
              watch(_bbsViewModel).startCreate();
            },
          );
          return Visibility(
            visible: !edit,
            child: button,
          );
        },
      );
}

class BbsPage extends HookWidget {
  final _keyStack = GlobalKey();
  final _keyForm = GlobalKey();

  static BbsPage factoryMethod() {
    return BbsPage();
  }

  @override
  Widget build(BuildContext context) {
    final result = useProvider(articlesStreamProvider);
    return result.when(
        data: (value) => _buildScreen(value),
        loading: () => Center(
              child: Text('loading'),
            ),
        error: (error, stackTrace) => Center(
              child: Text('error'),
            ));
  }

  Widget _buildScreen(QuerySnapshot<Article> snapshot) {
    final edit = useProvider(_editProvider).state;

    return Stack(
      key: _keyStack,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _buildBoard(snapshot),
        if (edit)
          Positioned(
            top: 20,
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildForm(),
            ),
          ),
        if (edit) _buildTools(),
      ],
    );
  }

  Widget _buildBoard(QuerySnapshot<Article> snapshot) {
    final offset = useProvider(_offsetProvider).state;

    final papers = snapshot.docs.map((noticeDoc) {
      final notice = noticeDoc.data();
      return Positioned(
          left: offset.dx + notice.left.toDouble(),
          top: offset.dy + notice.top.toDouble(),
          child: Container(
            width: 120,
            height: 120,
            child: Center(
              child: Text(notice.text),
            ),
            decoration: BoxDecoration(
              color: Colors.red,
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
      onPanUpdate: useContext().read(_bbsViewModel).pan,
      child: Container(
        color: Colors.deepPurple,
        child: Stack(
          children: papers,
        ),
      ),
    );
  }

  Widget _buildForm() {
    final context = useContext();
    final form = useProvider(_formProvider).state;
    final controller = TextEditingController();
    controller.text = form.text;

    return Container(
      key: _keyForm,
      padding: EdgeInsets.all(4),
      width: 200,
      color: Colors.yellow,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        maxLength: 200,
        onChanged: (input) {
          context.read(_formProvider).state.text = input;
        },
        textInputAction: TextInputAction.done,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black54,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10),
          fillColor: Colors.white38,
          errorText: null,
          counterText: "",
          border: InputBorder.none,
          hintText: '投稿内容を記入してください',
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTools() {
    final context = useContext();

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
                    await context.read(_bbsViewModel).post(offset);
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
            context.read(_editProvider).state = false;
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
    final offset = read(_offsetProvider).state;
    read(_offsetProvider).state =
        offset.translate(details.delta.dx, details.delta.dy);
  }

  void startCreate() {
    read(_editProvider).state = true;
  }

  Future<void> post(Offset formOffset) async {
    final text = read(_formProvider).state.text;
    final offset = read(_offsetProvider).state;
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
    await read(articleRepository).save(newArticle);
    read(_editProvider).state = false;

    read(snackBarController)?.showSnackBar(
      SnackBar(
        content: Text('投稿しました'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

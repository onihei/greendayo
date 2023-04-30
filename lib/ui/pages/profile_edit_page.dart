import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/provider/socket_provider.dart';
import 'package:greendayo/repository/profile_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

final _pageControllerProvider = Provider.autoDispose<PageController>((ref) => PageController());

final _viewControllerProvider = Provider.autoDispose<_ViewController>((ref) => _ViewController(ref));

final _loadingProvider = StateProvider<bool>((ref) => false);

class _FormNotifier extends StateNotifier<ProfileForm> {
  _FormNotifier(ProfileForm initial) : super(initial);

  void changeNickname(String text) {
    state = state.copyWith(nickname: text);
  }

  void changeAge(String text) {
    state = state.copyWith(age: text);
  }

  void changeBorn(String text) {
    state = state.copyWith(born: text);
  }

  void changeJob(String text) {
    state = state.copyWith(job: text);
  }

  void changeInteresting(String text) {
    state = state.copyWith(interesting: text);
  }

  void changeBook(String text) {
    state = state.copyWith(book: text);
  }

  void changeMovie(String text) {
    state = state.copyWith(movie: text);
  }

  void changeGoal(String text) {
    state = state.copyWith(goal: text);
  }

  void changeTreasure(String text) {
    state = state.copyWith(treasure: text);
  }
}

final _formProvider = StateNotifierProvider.autoDispose<_FormNotifier, ProfileForm>((ref) {
  final myProfile = ref.watch(myProfileProvider);
  final initialForm = ProfileForm();
  initialForm.nickname = myProfile.nickname;
  initialForm.age = myProfile.age;
  initialForm.born = myProfile.born;
  initialForm.job = myProfile.job;
  initialForm.interesting = myProfile.interesting;
  initialForm.book = myProfile.book;
  initialForm.movie = myProfile.movie;
  initialForm.goal = myProfile.goal;
  initialForm.treasure = myProfile.treasure;
  return _FormNotifier(initialForm);
});

class ProfileForm {
  ProfileForm();

  String? nickname;
  String? age;
  String? born;
  String? job;
  String? interesting;
  String? book;
  String? movie;
  String? goal;
  String? treasure;

  ProfileForm copyWith({
    String? nickname,
    String? age,
    String? born,
    String? job,
    String? interesting,
    String? book,
    String? movie,
    String? goal,
    String? treasure,
  }) {
    final form = ProfileForm();
    form.nickname = nickname ?? this.nickname;
    form.age = age ?? this.age;
    form.born = born ?? this.born;
    form.job = job ?? this.job;
    form.interesting = interesting ?? this.interesting;
    form.book = book ?? this.book;
    form.movie = movie ?? this.movie;
    form.goal = goal ?? this.goal;
    form.treasure = treasure ?? this.treasure;
    return form;
  }
}

class _ViewController {
  final Ref ref;

  _ViewController(this.ref);

  Future<void> save() async {
    ref.read(_loadingProvider.notifier).state = true;
    final text = await generateProfileText();

    final form = ref.read(_formProvider);
    final myProfile = ref.read(myProfileProvider);
    final entity = myProfile.copyWith(
      nickname: form.nickname,
      age: form.age,
      born: form.born,
      job: form.job,
      interesting: form.interesting,
      book: form.book,
      movie: form.movie,
      goal: form.goal,
      treasure: form.treasure,
      text: text,
    );
    ref.read(profileRepository).save(entity);
    ref.read(_loadingProvider.notifier).state = false;
  }

  Future<String> generateProfileText() async {
    final socket = ref.read(socketProvider);

    final form = ref.read(_formProvider);
    final param = {
      "nickname": form.nickname,
      "age": form.age,
      "born": form.born,
      "job": form.job,
      "interesting": form.interesting,
      "book": form.book,
      "movie": form.movie,
      "goal": form.goal,
      "treasure": form.treasure,
    };
    final completer = Completer<String>();
    socket.emitWithAck("generateProfileText", param, ack: (data) {
      final text = data as String;
      completer.complete(text);
    });
    final text = await completer.future;
    return text;
  }

  Future<void> uploadPhoto() async {
    final snackBar = ref.read(snackBarController);
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result == null) {
      return;
    }
    ref.read(_loadingProvider.notifier).state = true;
    final resultBytes = await result.readAsBytes();
    final tempImage = img.decodeImage(resultBytes);
    if (tempImage == null) {
      ref.read(_loadingProvider.notifier).state = false;
      snackBar?.showSnackBar(
        SnackBar(
          content: Text('ファイルの読み込みに失敗しました。'),
        ),
      );
      return;
    }
    final resized = img.copyResize(tempImage, width: 500);
    final bytes = img.encodeJpg(resized).buffer.asUint8List();
    await ref.read(profileRepository).uploadMyProfilePhoto("image/jpeg", bytes);
  }
}

class ProfileEditPage extends ConsumerWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(socketProvider);

    final myProfile = ref.watch(myProfileProvider);
    final pageController = ref.watch(_pageControllerProvider);
    ref.watch(avatarProvider(myProfile.userId).future).then((_) {
      ref.read(_loadingProvider.notifier).state = false;
    });

    final items = [
      _nickname(context, ref),
      _age(context, ref),
      _born(context, ref),
      _job(context, ref),
      _interesting(context, ref),
      _book(context, ref),
      _movie(context, ref),
      _goal(context, ref),
      _treasure(context, ref),
    ];
    final padding = MediaQuery.of(context).size.width / 100;
    final largeScreen = MediaQuery.of(context).viewInsets.bottom == 0;
    final photo = AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: largeScreen ? myProfile.photoLarge : myProfile.photoMiddle,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
    );

    final body = SingleChildScrollView(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Stack(
                children: [
                  photo,
                  // 画像にリップルエフェクトを加えるトリック
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(80),
                        onTap: () async {
                          await ref.read(_viewControllerProvider).uploadPhoto();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 250),
              child: Stack(
                children: [
                  PageView(
                    controller: pageController,
                    children: items,
                  ),
                  Align(
                    alignment: Alignment(0, 0.9),
                    child: _indicator(context, ref, items),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("プロフィールの設定"),
      ),
      body: Stack(
        children: [
          body,
          Consumer(
            builder: (context, ref, child) {
              final loading = ref.watch(_loadingProvider);
              if (!loading) {
                return SizedBox.shrink();
              }
              return Container(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _nickname(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final controller = ref.watch(textEditingControllerProvider("nickname"));
    controller.value = controller.value.copyWith(text: form.nickname);
    final text = "名前またはニックネーム";
    return _form(context, ref, text, controller, isFirst: true, autofocus: false, onChanged: (input) {
      ref.read(_formProvider.notifier).changeNickname(input);
    });
  }

  Widget _age(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final controller = ref.watch(textEditingControllerProvider("age"));
    controller.value = controller.value.copyWith(text: form.age);
    final text = "年齢を教えて";
    return _form(context, ref, text, controller, onChanged: (input) {
      ref.read(_formProvider.notifier).changeAge(input);
    });
  }

  Widget _born(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final controller = ref.watch(textEditingControllerProvider("born"));
    controller.value = controller.value.copyWith(text: form.born);
    final text = "出身地はどこ？";
    return _form(context, ref, text, controller, onChanged: (input) {
      ref.read(_formProvider.notifier).changeBorn(input);
    });
  }

  Widget _job(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final controller = ref.watch(textEditingControllerProvider("job"));
    controller.value = controller.value.copyWith(text: form.job);
    final text = "どんな仕事？";
    return _form(context, ref, text, controller, maxLength: 20, onChanged: (input) {
      ref.read(_formProvider.notifier).changeJob(input);
    });
  }

  Widget _interesting(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final controller = ref.watch(textEditingControllerProvider("interesting"));
    controller.value = controller.value.copyWith(text: form.interesting);
    final text = "興味のあることは？";
    return _form(context, ref, text, controller, maxLength: 20, onChanged: (input) {
      ref.read(_formProvider.notifier).changeInteresting(input);
    });
  }

  Widget _book(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final controller = ref.watch(textEditingControllerProvider("book"));
    controller.value = controller.value.copyWith(text: form.book);
    final text = "好きな本は";
    return _form(context, ref, text, controller, maxLength: 20, onChanged: (input) {
      ref.read(_formProvider.notifier).changeBook(input);
    });
  }

  Widget _movie(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final controller = ref.watch(textEditingControllerProvider("movie"));
    controller.value = controller.value.copyWith(text: form.movie);
    final text = "好きな映画は";
    return _form(context, ref, text, controller, maxLength: 20, onChanged: (input) {
      ref.read(_formProvider.notifier).changeMovie(input);
    });
  }

  Widget _goal(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final controller = ref.watch(textEditingControllerProvider("goal"));
    controller.value = controller.value.copyWith(text: form.goal);
    final text = "目標は？";
    return _form(context, ref, text, controller, maxLength: 20, onChanged: (input) {
      ref.read(_formProvider.notifier).changeGoal(input);
    });
  }

  Widget _treasure(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final controller = ref.watch(textEditingControllerProvider("treasure"));
    controller.value = controller.value.copyWith(text: form.treasure);
    final text = "人生の宝物は？";
    return _form(context, ref, text, controller, maxLength: 20, isLast: true, onChanged: (input) {
      ref.read(_formProvider.notifier).changeTreasure(input);
    });
  }

  Widget _form(BuildContext context, WidgetRef ref, String text, TextEditingController controller,
      {bool isFirst = false,
      bool isLast = false,
      int maxLength = 10,
      bool autofocus = true,
      Function(String input)? onChanged}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 400, height: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text),
              TextField(
                autofocus: autofocus,
                controller: controller,
                keyboardType: TextInputType.text,
                maxLines: null,
                maxLength: maxLength,
                onChanged: onChanged,
                onSubmitted: (input) async {
                  await ref
                      .read(_pageControllerProvider)
                      .nextPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
                },
                textInputAction: TextInputAction.done,
                buildCounter: (_, {required currentLength, maxLength, required isFocused}) => Row(
                  children: [
                    Text('$currentLength / $maxLength'),
                  ],
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isFirst) ...[
                    ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(_pageControllerProvider)
                              .previousPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
                        },
                        child: Text("前へ")),
                    SizedBox(
                      width: 16,
                    ),
                  ],
                  if (!isLast)
                    ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(_pageControllerProvider)
                              .nextPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
                        },
                        child: Text("次へ")),
                  if (isLast)
                    ElevatedButton(
                        onPressed: () async {
                          await ref.read(_viewControllerProvider).save();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Text("完了")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicator(BuildContext context, WidgetRef ref, List<Widget> items) {
    final pageController = ref.watch(_pageControllerProvider);
    return SmoothPageIndicator(
      controller: pageController, // PageController
      count: items.length,
      effect: WormEffect(), // your preferred effect
    );
  }
}

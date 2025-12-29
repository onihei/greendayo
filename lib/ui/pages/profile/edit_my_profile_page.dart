import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greendayo/domain/model/backend_socket.dart';
import 'package:greendayo/domain/model/profile.dart';
import 'package:greendayo/repository/profile_repository.dart';
import 'package:greendayo/ui/fragments/blocking_overlay.dart';
import 'package:greendayo/ui/fragments/profile_photo.dart';
import 'package:greendayo/ui/utils/snackbars.dart';
import 'package:greendayo/web/my_image_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

part 'edit_my_profile_page.g.dart';

@riverpod
class _ViewController extends _$ViewController {
  @override
  _ViewController build() {
    return this;
  }

  Future<void> save({
    required String nickname,
    required String age,
    required String born,
    required String job,
    required String interesting,
    required String book,
    required String movie,
    required String goal,
    required String treasure,
  }) async {
    final text = await generateProfileText(
      nickname: nickname,
      age: age,
      born: born,
      job: job,
      interesting: interesting,
      book: book,
      movie: movie,
      goal: goal,
      treasure: treasure,
    );

    final myProfile = await ref.read(myProfileProvider.future);
    final entity = myProfile.copyWith(
      nickname: nickname,
      age: age,
      born: born,
      job: job,
      interesting: interesting,
      book: book,
      movie: movie,
      goal: goal,
      treasure: treasure,
      text: text,
    );
    await ref.read(profileRepositoryProvider).save(entity);
  }

  Future<String> generateProfileText({
    required String nickname,
    required String age,
    required String born,
    required String job,
    required String interesting,
    required String book,
    required String movie,
    required String goal,
    required String treasure,
  }) async {
    final socket = ref.read(backendSocketProvider);

    final param = {
      "nickname": nickname,
      "age": age,
      "born": born,
      "job": job,
      "interesting": interesting,
      "book": book,
      "movie": movie,
      "goal": goal,
      "treasure": treasure,
    };
    final completer = Completer<String>();
    socket.emitWithAck(
      "generateProfileText",
      param,
      ack: (data) {
        final text = data as String;
        completer.complete(text);
      },
    );
    final text = await completer.future;
    return text;
  }

  Future<void> uploadPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result == null) {
      return;
    }
    if (!context.mounted) {
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
    if (!context.mounted) {
      return;
    }
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
    await ref
        .watch(profileRepositoryProvider)
        .uploadMyProfilePhoto("image/jpeg", bytes);
  }
}

class EditMyProfilePage extends HookConsumerWidget {
  const EditMyProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(backendSocketProvider);
    final vc = ref.watch(_viewControllerProvider);

    final myProfile = ref.watch(myProfileProvider).requireValue;
    final pageController = usePageController();
    final nicknameController =
        useTextEditingController(text: myProfile.nickname);
    final ageController = useTextEditingController(text: myProfile.age);
    final bornController = useTextEditingController(text: myProfile.born);
    final jobController = useTextEditingController(text: myProfile.job);
    final interestingController =
        useTextEditingController(text: myProfile.interesting);
    final bookController = useTextEditingController(text: myProfile.book);
    final movieController = useTextEditingController(text: myProfile.movie);
    final goalController = useTextEditingController(text: myProfile.goal);
    final treasureController =
        useTextEditingController(text: myProfile.treasure);

    void onPrevious() {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }

    void onNext() {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }

    final items = [
      _formField(
        context,
        ref,
        label: '名前またはニックネーム',
        controller: nicknameController,
        onNext: onNext,
      ),
      _formField(
        context,
        ref,
        label: '年齢を教えて',
        controller: ageController,
        onPrevious: onPrevious,
        onNext: onNext,
      ),
      _formField(
        context,
        ref,
        label: '出身地はどこ？',
        controller: bornController,
        onPrevious: onPrevious,
        onNext: onNext,
      ),
      _formField(
        context,
        ref,
        label: 'どんな仕事？',
        controller: jobController,
        onPrevious: onPrevious,
        onNext: onNext,
      ),
      _formField(
        context,
        ref,
        label: '興味のあることは？',
        controller: interestingController,
        onPrevious: onPrevious,
        onNext: onNext,
      ),
      _formField(
        context,
        ref,
        label: '好きな本は',
        controller: bookController,
        onPrevious: onPrevious,
        onNext: onNext,
      ),
      _formField(
        context,
        ref,
        label: '好きな映画は',
        controller: movieController,
        onPrevious: onPrevious,
        onNext: onNext,
      ),
      _formField(
        context,
        ref,
        label: '目標は',
        controller: goalController,
        onPrevious: onPrevious,
        onNext: onNext,
      ),
      _formField(
        context,
        ref,
        label: '人生の宝物は？',
        controller: treasureController,
        onPrevious: onPrevious,
        onNext: () async {
          await vc.save(
            nickname: nicknameController.text,
            age: ageController.text,
            born: bornController.text,
            job: jobController.text,
            interesting: interestingController.text,
            book: bookController.text,
            movie: movieController.text,
            goal: goalController.text,
            treasure: treasureController.text,
          );
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
        nextLabel: '保存して終了',
      ),
    ];

    final body = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 220,
                child: PageView(controller: pageController, children: items),
              ),
              _indicator(context, ref, items, pageController),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: BlockingOverlay(
              child: Stack(
                children: [
                  ProfilePhoto(profile: myProfile, size: 160),
                  // 画像にリップルエフェクトを加えるトリック
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(80),
                        onTap: () async {
                          await ref.read(blockingProvider.notifier).blockWhile(
                            operation: () async {
                              await vc.uploadPhoto(context);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("プロフィールの設定")),
      body: body,
    );
  }

  Widget _formField(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required TextEditingController controller,
    Function()? onPrevious,
    required Function() onNext,
    String nextLabel = '次へ',
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 400, height: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                maxLines: null,
                maxLength: 20,
                onSubmitted: (input) async {
                  onNext.call();
                },
                textInputAction: TextInputAction.done,
                buildCounter: (
                  _, {
                  required currentLength,
                  maxLength,
                  required isFocused,
                }) {
                  return Row(children: [Text('$currentLength / $maxLength')]);
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onPrevious != null) ...[
                    ElevatedButton(
                      onPressed: onPrevious.call,
                      child: const Text("前へ"),
                    ),
                    const SizedBox(width: 16),
                  ],
                  ElevatedButton(
                    onPressed: onNext.call,
                    child: Text(nextLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicator(BuildContext context, WidgetRef ref, List<Widget> items,
      PageController pageController) {
    return SmoothPageIndicator(
      controller: pageController, // PageController
      count: items.length,
      effect: WormEffect(
        activeDotColor: Theme.of(context).colorScheme.secondary,
      ), // your preferred effect
    );
  }
}

import 'package:flutter/material.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/provider/profile_provider.dart';
import 'package:greendayo/repository/profile_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

final _pageControllerProvider = Provider.autoDispose<PageController>((ref) => PageController());
final _nicknameControllerProvider = Provider.autoDispose<TextEditingController>((ref) => TextEditingController());
final _ageControllerProvider = Provider.autoDispose<TextEditingController>((ref) => TextEditingController());
final _bornControllerProvider = Provider.autoDispose<TextEditingController>((ref) => TextEditingController());
final _jobControllerProvider = Provider.autoDispose<TextEditingController>((ref) => TextEditingController());
final _interestingControllerProvider = Provider.autoDispose<TextEditingController>((ref) => TextEditingController());
final _bookControllerProvider = Provider.autoDispose<TextEditingController>((ref) => TextEditingController());
final _movieControllerProvider = Provider.autoDispose<TextEditingController>((ref) => TextEditingController());
final _goalControllerProvider = Provider.autoDispose<TextEditingController>((ref) => TextEditingController());
final _treasureControllerProvider = Provider.autoDispose<TextEditingController>((ref) => TextEditingController());

final _viewControllerProvider = Provider.autoDispose<_ViewController>((ref) => _ViewController(ref));

class _ViewController {
  final Ref ref;

  _ViewController(this.ref);

  Future<void> save() async {
    final myProfile = ref.read(myProfileProvider);
    final entity = myProfile.copyWith(
      nickname: ref.read(_nicknameControllerProvider).value.text,
      age: ref.read(_ageControllerProvider).value.text,
      born: ref.read(_bornControllerProvider).value.text,
      job: ref.read(_jobControllerProvider).value.text,
      interesting: ref.read(_interestingControllerProvider).value.text,
      book: ref.read(_bookControllerProvider).value.text,
      movie: ref.read(_movieControllerProvider).value.text,
      goal: ref.read(_goalControllerProvider).value.text,
      treasure: ref.read(_treasureControllerProvider).value.text,
    );
    ref.read(profileRepository).save(entity);
    ref.invalidate(profileProvider(myProfile.userId));
    ref.read(myProfileProvider.notifier).state = entity;
  }
}

class ProfileEditPage extends ConsumerWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = ref.watch(_pageControllerProvider);

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

    return Scaffold(
      appBar: AppBar(
        title: Text("プロフィールの設定"),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        alignment: Alignment.center,
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
    );
  }

  Widget _nickname(BuildContext context, WidgetRef ref) {
    final myProfile = ref.watch(myProfileProvider);
    final controller = ref.watch(_nicknameControllerProvider);
    controller.text = myProfile.nickname;
    final text = "名前またはニックネーム";
    return _form(context, ref, text, controller, isFirst: true);
  }

  Widget _age(BuildContext context, WidgetRef ref) {
    final myProfile = ref.watch(myProfileProvider);
    final controller = ref.watch(_ageControllerProvider);
    controller.text = myProfile.age ?? "";
    final text = "年齢を教えて";
    return _form(context, ref, text, controller);
  }

  Widget _born(BuildContext context, WidgetRef ref) {
    final myProfile = ref.watch(myProfileProvider);
    final controller = ref.watch(_bornControllerProvider);
    controller.text = myProfile.born ?? "";
    final text = "出身地はどこ？";
    return _form(context, ref, text, controller);
  }

  Widget _job(BuildContext context, WidgetRef ref) {
    final myProfile = ref.watch(myProfileProvider);
    final controller = ref.watch(_jobControllerProvider);
    controller.text = myProfile.job ?? "";
    final text = "どんな仕事？";
    return _form(context, ref, text, controller, maxLength: 20);
  }

  Widget _interesting(BuildContext context, WidgetRef ref) {
    final myProfile = ref.watch(myProfileProvider);
    final controller = ref.watch(_interestingControllerProvider);
    controller.text = myProfile.interesting ?? "";
    final text = "興味のあることは？";
    return _form(context, ref, text, controller, maxLength: 20);
  }

  Widget _book(BuildContext context, WidgetRef ref) {
    final myProfile = ref.watch(myProfileProvider);
    final controller = ref.watch(_bookControllerProvider);
    controller.text = myProfile.book ?? "";
    final text = "好きな本は";
    return _form(context, ref, text, controller, maxLength: 20);
  }

  Widget _movie(BuildContext context, WidgetRef ref) {
    final myProfile = ref.watch(myProfileProvider);
    final controller = ref.watch(_movieControllerProvider);
    controller.text = myProfile.movie ?? "";
    final text = "好きな映画は";
    return _form(context, ref, text, controller, maxLength: 20);
  }

  Widget _goal(BuildContext context, WidgetRef ref) {
    final myProfile = ref.watch(myProfileProvider);
    final controller = ref.watch(_goalControllerProvider);
    controller.text = myProfile.goal ?? "";
    final text = "目標は？";
    return _form(context, ref, text, controller, maxLength: 20);
  }

  Widget _treasure(BuildContext context, WidgetRef ref) {
    final myProfile = ref.watch(myProfileProvider);
    final controller = ref.watch(_treasureControllerProvider);
    controller.text = myProfile.treasure ?? "";
    final text = "人生の宝物は？";
    return _form(context, ref, text, controller, maxLength: 20, isLast: true);
  }

  Widget _form(BuildContext context, WidgetRef ref, String text, TextEditingController controller,
      {bool isFirst = false, bool isLast = false, int maxLength = 10}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text),
              TextField(
                autofocus: true,
                controller: controller,
                keyboardType: TextInputType.text,
                maxLines: null,
                maxLength: maxLength,
                onChanged: (input) {},
                textInputAction: TextInputAction.next,
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

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greendayo/features/bbs/bbs_controller.dart';
import 'package:greendayo/features/profile/profile_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bbs_form.g.dart';

// --- State ---

class BbsFormState {
  final String text;
  final double width;
  final Uint8List? photoJpgBytes;
  final double rotation;

  const BbsFormState({
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

  BbsFormState copyWith({
    String? text,
    double? width,
    double? rotation,
  }) {
    return BbsFormState(
      text: text ?? this.text,
      width: width ?? this.width,
      photoJpgBytes: photoJpgBytes,
      rotation: rotation ?? this.rotation,
    );
  }

  BbsFormState copyWithPhotoJpgBytes(Uint8List? bytes) {
    return BbsFormState(
      text: text,
      width: width,
      photoJpgBytes: bytes,
      rotation: rotation,
    );
  }
}

// --- Providers ---

@riverpod
class BbsForm extends _$BbsForm {
  @override
  BbsFormState build() => const BbsFormState();

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
    state = const BbsFormState();
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
class BbsFormEnabled extends _$BbsFormEnabled {
  @override
  bool build() => false;

  void setEnabled(bool enabled) {
    state = enabled;
  }
}

@riverpod
class BbsScale extends _$BbsScale {
  @override
  double build() => 1.0;

  void setScale(double scale) {
    state = scale;
  }
}

@riverpod
class BbsOffset extends _$BbsOffset {
  @override
  Offset build() => Offset.zero;

  void setOffset(Offset offset) {
    state = offset;
  }
}

// --- Widgets ---

class BbsFormWidget extends HookConsumerWidget {
  const BbsFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(bbsFormProvider);
    if (form.isPhotoMode) {
      return _photoForm(context, ref);
    } else {
      return _textForm(context, ref);
    }
  }

  Widget _photoForm(BuildContext context, WidgetRef ref) {
    final vc = ref.watch(bbsControllerProvider);
    final form = ref.watch(bbsFormProvider);
    final content = Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      width: form.width,
      height: form.width + 16,
      decoration: photoBoxDecoration(context),
      child: form.photo,
    );
    return Container(
      key: vc.formKey,
      child: Transform.rotate(angle: form.rotation, child: content),
    );
  }

  Widget _textForm(BuildContext context, WidgetRef ref) {
    final vc = ref.watch(bbsControllerProvider);
    final form = ref.watch(bbsFormProvider);
    final controller = useTextEditingController();
    final myProfile = ref.watch(myProfileProvider).requireValue;
    return Container(
      key: vc.formKey,
      padding: const EdgeInsets.all(4),
      width: form.width,
      decoration: textBoxDecoration(
        context,
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        maxLength: 200,
        onChanged: (input) {
          ref.read(bbsFormProvider.notifier).changeText(input);
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
}

class BbsEditActions extends ConsumerWidget {
  const BbsEditActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vc = ref.watch(bbsControllerProvider);
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
                ref.read(bbsFormProvider.notifier).changePhotoJpgBytes(null);
                ref.read(bbsFormEnabledProvider.notifier).setEnabled(false);
              },
              child: const Text('キャンセル'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Shared decorations ---

BoxDecoration textBoxDecoration(BuildContext context, {required Color color}) {
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

BoxDecoration photoBoxDecoration(BuildContext context) {
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

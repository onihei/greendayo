// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profile)
final profileProvider = ProfileFamily._();

final class ProfileProvider
    extends $FunctionalProvider<AsyncValue<Profile>, Profile, FutureOr<Profile>>
    with $FutureModifier<Profile>, $FutureProvider<Profile> {
  ProfileProvider._(
      {required ProfileFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'profileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileHash();

  @override
  String toString() {
    return r'profileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Profile> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile> create(Ref ref) {
    final argument = this.argument as String;
    return profile(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileHash() => r'e86b70e1cb598ae014701eba86e3f3be2c90bc6a';

final class ProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Profile>, String> {
  ProfileFamily._()
      : super(
          retry: null,
          name: r'profileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ProfileProvider call(
    String uid,
  ) =>
      ProfileProvider._(argument: uid, from: this);

  @override
  String toString() => r'profileProvider';
}

/// 自分のプロフィールを取得するProvider
/// ユーザーが認証されていない場合は例外をスローする
/// Home 画面で watch するので、以降の機能では requiredValue を使う

@ProviderFor(myProfile)
final myProfileProvider = MyProfileProvider._();

/// 自分のプロフィールを取得するProvider
/// ユーザーが認証されていない場合は例外をスローする
/// Home 画面で watch するので、以降の機能では requiredValue を使う

final class MyProfileProvider
    extends $FunctionalProvider<AsyncValue<Profile>, Profile, FutureOr<Profile>>
    with $FutureModifier<Profile>, $FutureProvider<Profile> {
  /// 自分のプロフィールを取得するProvider
  /// ユーザーが認証されていない場合は例外をスローする
  /// Home 画面で watch するので、以降の機能では requiredValue を使う
  MyProfileProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'myProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$myProfileHash();

  @$internal
  @override
  $FutureProviderElement<Profile> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile> create(Ref ref) {
    return myProfile(ref);
  }
}

String _$myProfileHash() => r'01e76e6aa3e8301106c64d797f5faa417404aa09';

@ProviderFor(profilePhotoUrl)
final profilePhotoUrlProvider = ProfilePhotoUrlFamily._();

final class ProfilePhotoUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  ProfilePhotoUrlProvider._(
      {required ProfilePhotoUrlFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'profilePhotoUrlProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profilePhotoUrlHash();

  @override
  String toString() {
    return r'profilePhotoUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return profilePhotoUrl(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfilePhotoUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profilePhotoUrlHash() => r'4a0671201fd68e22897f5e582be00349e727e511';

final class ProfilePhotoUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  ProfilePhotoUrlFamily._()
      : super(
          retry: null,
          name: r'profilePhotoUrlProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ProfilePhotoUrlProvider call(
    String uid,
  ) =>
      ProfilePhotoUrlProvider._(argument: uid, from: this);

  @override
  String toString() => r'profilePhotoUrlProvider';
}

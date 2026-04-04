// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

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

String _$myProfileHash() => r'253a7a12774682bb442ca8299d10f9d4d566ce1c';

@ProviderFor(profilePhotoUrl)
final profilePhotoUrlProvider = ProfilePhotoUrlFamily._();

final class ProfilePhotoUrlProvider
    extends $FunctionalProvider<String, String, String> with $Provider<String> {
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
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as String;
    return profilePhotoUrl(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
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

String _$profilePhotoUrlHash() => r'52468b9213e8570305b73b418dcb1350c824c77f';

final class ProfilePhotoUrlFamily extends $Family
    with $FunctionalFamilyOverride<String, String> {
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

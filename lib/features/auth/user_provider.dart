import 'package:firebase_auth/firebase_auth.dart';
import 'package:greendayo/shared/firebase/firebase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<User?> user(Ref ref) async* {
  final auth = ref.read(firebaseAuthProvider);
  yield auth.currentUser;
  await for (User? user in auth.authStateChanges()) {
    yield user;
  }
}

@Riverpod(keepAlive: true)
class SelectedUserId extends _$SelectedUserId {
  @override
  String? build() {
    return null;
  }

  void select(String? userId) {
    state = userId;
  }

  void clear() {
    state = null;
  }
}

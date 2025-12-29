import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user.g.dart';

@riverpod
Stream<User?> user(Ref ref) async* {
  yield FirebaseAuth.instance.currentUser;
  await for (User? user in FirebaseAuth.instance.authStateChanges()) {
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

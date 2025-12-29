import 'package:greendayo/domain/model/profile.dart';
import 'package:greendayo/entity/session.dart';
import 'package:greendayo/entity/talk.dart';
import 'package:greendayo/repository/session_repository.dart';
import 'package:greendayo/repository/talk_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'talk_use_case.g.dart';

@riverpod
class TalkUseCase extends _$TalkUseCase {
  @override
  TalkUseCase build() {
    return this;
  }

  Future<void> createTalk({
    required String sessionId,
    required String text,
  }) async {
    final myProfile = await ref.read(myProfileProvider.future);
    final newTalk = Talk(
      content: text,
      sender: myProfile.userId,
      createdAt: DateTime.now(),
    );
    await ref.read(talkRepositoryProvider(sessionId)).save(newTalk);
    await ref.read(sessionRepositoryProvider).updateTimestamp(sessionId);
  }

  Future<String> createSession({
    required String userId,
    required String text,
  }) async {
    final myProfile = await ref.read(myProfileProvider.future);
    assert(myProfile.userId != userId);

    final now = DateTime.now();
    final newSession = Session(
      members: [myProfile.userId, userId],
      updatedAt: now,
    );
    final newSessionId =
        await ref.read(sessionRepositoryProvider).save(newSession);

    final newTalk = Talk(
      content: text,
      sender: myProfile.userId,
      createdAt: now,
    );
    await ref.read(talkRepositoryProvider(newSessionId)).save(newTalk);
    return newSessionId;
  }

  Future<void> deleteSession({required String sessionId}) async {
    await ref.read(sessionRepositoryProvider).delete(sessionId);
  }
}

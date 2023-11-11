import 'package:greendayo/entity/session.dart';
import 'package:greendayo/entity/talk.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/repository/session_repository.dart';
import 'package:greendayo/repository/talk_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final talkUseCase =
    Provider.autoDispose<TalkUseCase>((ref) => TalkUseCase(ref));

class TalkUseCase {
  final Ref ref;

  TalkUseCase(this.ref);

  Future<void> createTalk(
      {required String sessionId, required String text}) async {
    final myProfile = await ref.read(myProfileProvider.future);
    final newTalk = Talk(
      content: text,
      sender: myProfile.userId,
      createdAt: DateTime.now(),
    );
    await ref.read(talkRepository(sessionId)).save(newTalk);
    await ref.read(sessionRepository).updateTimestamp(sessionId);
  }

  Future<String> createSession(
      {required String userId, required String text}) async {
    final myProfile = await ref.read(myProfileProvider.future);
    assert(myProfile.userId != userId);

    final now = DateTime.now();
    final newSession = Session(
      members: [myProfile.userId, userId],
      updatedAt: now,
    );
    final newSessionId = await ref.read(sessionRepository).save(newSession);

    final newTalk = Talk(
      content: text,
      sender: myProfile.userId,
      createdAt: now,
    );
    await ref.read(talkRepository(newSessionId)).save(newTalk);
    return newSessionId;
  }

  Future<void> deleteSession({required String sessionId}) async {
    await ref.read(sessionRepository).delete(sessionId);
  }
}

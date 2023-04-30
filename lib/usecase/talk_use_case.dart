import 'package:greendayo/entity/talk.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/repository/session_repository.dart';
import 'package:greendayo/repository/talk_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final talkUseCase = Provider.autoDispose<TalkUseCase>((ref) => TalkUseCase(ref));

class TalkUseCase {
  final Ref ref;

  TalkUseCase(this.ref);

  Future<void> createTalk({required String sessionId, required String text}) async {
    final myProfile = ref.read(myProfileProvider);
    final newTalk = Talk(
      content: text,
      sender: myProfile.userId,
      createdAt: DateTime.now(),
    );
    await ref.read(talkRepository(sessionId)).save(newTalk);
    await ref.read(sessionRepository).updateTimestamp(sessionId);
  }
}

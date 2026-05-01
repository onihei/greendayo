"use client";

import { use, useState } from "react";
import Link from "next/link";
import { AppShell } from "@/components/layout/app-shell";
import { TalkView } from "@/components/messenger/talk-view";
import { useProfile } from "@/lib/hooks/use-profile";
import { useMyProfile } from "@/lib/hooks/use-my-profile";
import { useRouter } from "next/navigation";

export default function ProfilePage({
  params,
}: {
  params: Promise<{ userId: string }>;
}) {
  const { userId } = use(params);
  const { profile, ready } = useProfile(userId);
  const { profile: me } = useMyProfile();
  const router = useRouter();
  const [composing, setComposing] = useState(false);
  const isMe = me?.userId === userId;

  if (!ready) {
    return (
      <AppShell title="プロフィール">
        <div className="p-6 text-muted">読み込み中…</div>
      </AppShell>
    );
  }
  if (!profile) {
    return (
      <AppShell title="プロフィール">
        <div className="p-6 text-muted">プロフィールが見つかりません</div>
      </AppShell>
    );
  }

  return (
    <AppShell title={`プロフィール${isMe ? " (自分)" : ""}`}>
      {composing && me && !isMe ? (
        <div className="h-[calc(100dvh-7rem)]">
          <TalkView
            sessionId={null}
            destinationUserId={profile.userId}
            onSessionCreated={(id) => router.push(`/messenger/${id}`)}
          />
        </div>
      ) : (
        <div className="mx-auto max-w-md p-6 text-center">
          {profile.photoUrl && (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={profile.photoUrl}
              alt=""
              className="mx-auto h-32 w-32 rounded-full object-cover"
            />
          )}
          <h2 className="mt-3 text-lg font-bold">{profile.nickname}</h2>
          <p className="mt-6 whitespace-pre-wrap text-left text-foreground">
            {profile.text ?? `こんにちは！私は${profile.nickname}`}
          </p>
          <div className="mt-8 flex justify-center gap-3">
            {isMe && (
              <Link
                href="/profile/me/edit"
                className="rounded bg-primary px-4 py-2 font-bold text-on-primary"
              >
                編集
              </Link>
            )}
            {!isMe && me && (
              <button
                type="button"
                onClick={() => setComposing(true)}
                className="rounded bg-primary px-4 py-2 font-bold text-on-primary"
              >
                メッセージを送る
              </button>
            )}
          </div>
        </div>
      )}
    </AppShell>
  );
}

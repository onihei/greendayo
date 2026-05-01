"use client";

import { use } from "react";
import { useRouter } from "next/navigation";
import { AppShell } from "@/components/layout/app-shell";
import { SessionList } from "@/components/messenger/session-list";
import { TalkView } from "@/components/messenger/talk-view";
import { useAuth } from "@/lib/hooks/use-auth";
import { useUiStore } from "@/stores/ui";

export default function MessengerSessionPage({
  params,
}: {
  params: Promise<{ sessionId: string }>;
}) {
  const { sessionId } = use(params);
  const { user, loading } = useAuth();
  const router = useRouter();
  const openLogin = useUiStore((s) => s.openLoginDialog);

  if (loading) return null;
  if (!user) {
    return (
      <AppShell title="メッセージ">
        <div className="flex h-[60dvh] flex-col items-center justify-center gap-4 text-muted">
          <p>ログインしてください</p>
          <button
            type="button"
            onClick={openLogin}
            className="rounded bg-primary px-4 py-2 font-bold text-on-primary"
          >
            ログイン
          </button>
        </div>
      </AppShell>
    );
  }

  return (
    <AppShell title="メッセージ">
      <div className="h-[calc(100dvh-7rem)]">
        <div className="hidden h-full md:grid md:grid-cols-[280px_1fr]">
          <div className="overflow-y-auto border-r border-surface-variant">
            <SessionList selectedSessionId={sessionId} onSelect={(id) => router.push(`/messenger/${id}`)} />
          </div>
          <TalkView sessionId={sessionId} />
        </div>
        <div className="h-full md:hidden">
          <TalkView sessionId={sessionId} />
        </div>
      </div>
    </AppShell>
  );
}
